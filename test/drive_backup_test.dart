import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nurday/data/backup.dart';
import 'package:nurday/data/db/database.dart';
import 'package:nurday/data/drive_backup.dart';

import 'helpers.dart';

/// A fake Drive app folder holding at most one file.
class FakeDrive {
  String? content;
  DateTime modified = DateTime.utc(2026, 10, 6, 8);
  final requests = <http.Request>[];
  int status = 200;

  late final client = MockClient((req) async {
    requests.add(req);
    if (req.headers['Authorization'] != 'Bearer tok') {
      return http.Response('', 401);
    }
    if (status != 200) return http.Response('', status);
    final path = req.url.path;
    if (req.method == 'GET' && path == '/drive/v3/files') {
      expect(req.url.queryParameters['spaces'], 'appDataFolder');
      return http.Response(
        jsonEncode({
          'files': [
            if (content != null)
              {'id': 'f1', 'modifiedTime': modified.toIso8601String()},
          ],
        }),
        200,
      );
    }
    if (req.method == 'GET' && path == '/drive/v3/files/f1') {
      return http.Response.bytes(utf8.encode(content!), 200);
    }
    if (req.method == 'POST' && path == '/upload/drive/v3/files') {
      final body = req.body;
      expect(body, contains('"parents":["appDataFolder"]'));
      final parts = body.split('--nurday-backup-boundary');
      content = parts[2].split('\r\n\r\n').skip(1).join('\r\n\r\n').trim();
      return http.Response('{"id":"f1"}', 200);
    }
    if (req.method == 'PATCH' && path == '/upload/drive/v3/files/f1') {
      content = req.body;
      return http.Response('{"id":"f1"}', 200);
    }
    return http.Response('not found', 404);
  });
}

void main() {
  late AppDatabase db;
  late FakeDrive drive;
  late FakeAuth auth;
  var now = DateTime(2026, 10, 7, 9);
  DriveSync sync() => DriveSync(
    db: db,
    auth: auth,
    drive: DriveBackup(drive.client),
    now: () => now,
  );

  setUp(() {
    db = memoryDb();
    drive = FakeDrive();
    auth = FakeAuth();
    now = DateTime(2026, 10, 7, 9);
  });
  tearDown(() => db.close());

  test('connect makes a first backup in the app folder', () async {
    await db.addHabit('Walk');
    expect(await sync().connect(), isTrue);
    expect(auth.prompts, [true]);
    expect(jsonDecode(drive.content!)['habits'][0]['name'], 'Walk');
    final s = await db.watchSettings().first;
    expect(s['driveBackup'], 'true');
    expect(DateTime.parse(s['driveLastBackup']!), now);
  });

  test('a cancelled Google dialog changes nothing', () async {
    auth.granted = false;
    expect(await sync().connect(), isFalse);
    expect((await db.watchSettings().first)['driveBackup'], isNull);
    expect(drive.content, isNull);
  });

  test('later backups replace the same file', () async {
    await sync().connect();
    await db.addHabit('Read');
    await sync().backUp();
    expect(drive.requests.where((r) => r.method == 'POST'), hasLength(1));
    expect(drive.requests.where((r) => r.method == 'PATCH'), hasLength(1));
    expect(drive.content, contains('Read'));
  });

  test('daily backup runs only when on and due, without a dialog', () async {
    await sync().backUpIfDue({});
    expect(auth.prompts, isEmpty);

    await sync().connect();
    auth.prompts.clear();
    now = now.add(const Duration(hours: 5));
    await sync().backUpIfDue(await db.watchSettings().first);
    expect(auth.prompts, isEmpty, reason: 'backed up 5 hours ago');

    now = now.add(const Duration(hours: 20));
    await sync().backUpIfDue(await db.watchSettings().first);
    expect(auth.prompts, [false]);

    // Errors in the background are swallowed.
    drive.status = 500;
    now = now.add(const Duration(days: 2));
    await sync().backUpIfDue(await db.watchSettings().first);
  });

  test(
    'restore merges the Drive copy and keeps the Drive connection',
    () async {
      await db.addHabit('Walk');
      await sync().connect();

      final other = memoryDb();
      addTearDown(other.close);
      await other.putSetting('driveBackup', 'true');
      final s = DriveSync(
        db: other,
        auth: auth,
        drive: DriveBackup(drive.client),
        now: () => now,
      );
      final summary = await s.restore(ImportMode.replace);
      expect(summary!.habits, 1);
      expect((await other.watchHabits().first).single.name, 'Walk');
      expect((await other.watchSettings().first)['driveBackup'], 'true');
    },
  );

  test('restore with no Drive copy returns null', () async {
    expect(await sync().restore(ImportMode.merge), isNull);
  });

  test('refused access is reported in plain words', () async {
    drive.status = 403;
    await expectLater(
      sync().backUp(),
      throwsA(
        isA<DriveException>().having(
          (e) => e.message,
          'message',
          contains('refused'),
        ),
      ),
    );
  });

  test('disconnect turns backups off and signs out', () async {
    await sync().connect();
    await sync().disconnect();
    expect((await db.watchSettings().first)['driveBackup'], 'false');
    expect(auth.signedOut, isTrue);
  });
}
