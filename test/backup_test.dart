import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/data/backup.dart';
import 'package:nurday/data/db/database.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 10, 7, 9);
  setUp(() => db = memoryDb());
  tearDown(() => db.close());

  Future<void> seed(AppDatabase d) async {
    final walk = await d.addHabit('Walk');
    final read = await d.addHabit('Read Quran');
    await d.toggleCompletion(walk, '2026-10-06');
    await d.toggleCompletion(read, '2026-10-07');
    await d.setMood('2026-10-07', 4, now);
    await d.saveJournal('2026-10-07', 'Calm day', 'Prayed on time.', now);
    await d.saveActivity(
      ActivitiesCompanion.insert(
        title: 'Run',
        startTime: '07:00',
        durationMinutes: 30,
        dayKey: '2026-10-07',
      ),
    );
    await d.putSetting('city', 'Rabat');
  }

  test('export then replace-import restores everything', () async {
    await seed(db);
    final json = await db.exportJson(now);
    expect(jsonDecode(json)['app'], 'nurday');

    final other = memoryDb();
    addTearDown(other.close);
    await other.addHabit('Something old');
    final summary = await other.importJson(json, ImportMode.replace);

    expect(summary.habits, 2);
    expect(summary.completions, 2);
    final habits = await other.watchHabits().first;
    expect(habits.map((h) => h.name), ['Walk', 'Read Quran']);
    expect(await other.watchCompletions().first, hasLength(2));
    expect((await other.watchMoods().first).single.value, 4);
    final j = (await other.watchJournals().first).single;
    expect(j.title, 'Calm day');
    expect(j.body, 'Prayed on time.');
    expect((await other.watchActivities().first).single.title, 'Run');
    expect((await other.watchSettings().first)['city'], 'Rabat');
  });

  test(
    'merge keeps local data, matches habits by name, skips duplicates',
    () async {
      await seed(db);
      final json = await db.exportJson(now);

      final other = memoryDb();
      addTearDown(other.close);
      final walk = await other.addHabit('walk ');
      await other.toggleCompletion(walk, '2026-10-05');
      await other.putSetting('city', 'Fes');
      // A newer journal on this phone wins over the file's.
      await other.saveJournal(
        '2026-10-07',
        'Mine',
        'Newer text',
        now.add(const Duration(hours: 2)),
      );

      final first = await other.importJson(json, ImportMode.merge);
      expect(first.habits, 1, reason: 'Walk matched by name');
      expect(first.journals, 0);
      final habits = await other.watchHabits().first;
      expect(habits.map((h) => h.name), ['walk ', 'Read Quran']);
      expect(await other.watchCompletions().first, hasLength(3));
      expect((await other.watchJournals().first).single.title, 'Mine');
      expect((await other.watchSettings().first)['city'], 'Fes');

      // Importing the same file again adds nothing.
      final again = await other.importJson(json, ImportMode.merge);
      expect(again.isEmpty, isTrue);
      expect(await other.watchActivities().first, hasLength(1));
    },
  );

  test('rejects files that are not Nurday backups without changing data', () async {
    await seed(db);
    for (final bad in [
      'not json',
      '{"app":"other","format":1}',
      '{"app":"nurday","format":1,"moods":[{"dayKey":"yesterday","value":1}]}',
    ]) {
      await expectLater(
        db.importJson(bad, ImportMode.replace),
        throwsA(isA<BackupException>()),
      );
    }
    expect(await db.watchHabits().first, hasLength(2));
  });

  test('rejects a backup from a newer app version', () async {
    expect(
      () => db.importJson('{"app":"nurday","format":99}', ImportMode.merge),
      throwsA(
        isA<BackupException>().having(
          (e) => e.message,
          'message',
          contains('newer version'),
        ),
      ),
    );
  });

  test('file name uses the date', () {
    expect(backupFileName(now), 'nurday-backup-2026-10-07.json');
  });
}
