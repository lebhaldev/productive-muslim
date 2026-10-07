import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

import 'backup.dart';
import 'db/database.dart';

/// Only the app's hidden folder in the user's own Drive; Nurday cannot see
/// any other file there.
const driveScope = 'https://www.googleapis.com/auth/drive.appdata';
const driveFileName = 'nurday-backup.json';

class DriveException implements Exception {
  const DriveException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Google authorization for the Drive app folder; faked in tests.
abstract interface class GoogleAuth {
  /// An access token, or null if the user has to be asked and [prompt] is
  /// false (background backups never show a dialog).
  Future<String?> token({required bool prompt});
  Future<void> signOut();
}

class GoogleSignInAuth implements GoogleAuth {
  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    await GoogleSignIn.instance.initialize();
    _ready = true;
  }

  @override
  Future<String?> token({required bool prompt}) async {
    try {
      await _init();
      final client = GoogleSignIn.instance.authorizationClient;
      final authz =
          await client.authorizationForScopes(const [driveScope]) ??
          (prompt ? await client.authorizeScopes(const [driveScope]) : null);
      return authz?.accessToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      throw const DriveException(
        'Google sign-in is not available. Try again later.',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _init();
      await GoogleSignIn.instance.disconnect();
    } catch (_) {}
  }
}

/// One backup file in the Drive app folder, via the Drive v3 REST API.
class DriveBackup {
  DriveBackup(this._http);
  final http.Client _http;

  static const _api = 'https://www.googleapis.com/drive/v3/files';
  static const _upload = 'https://www.googleapis.com/upload/drive/v3/files';

  Map<String, String> _auth(String token) => {'Authorization': 'Bearer $token'};

  Future<({String id, DateTime modified})?> _find(String token) async {
    final uri = Uri.parse(_api).replace(
      queryParameters: {
        'spaces': 'appDataFolder',
        'q': "name = '$driveFileName' and trashed = false",
        'fields': 'files(id, modifiedTime)',
        'orderBy': 'modifiedTime desc',
        'pageSize': '1',
      },
    );
    final res = await _send(() => _http.get(uri, headers: _auth(token)));
    final files = (jsonDecode(res.body) as Map)['files'] as List? ?? const [];
    if (files.isEmpty) return null;
    final f = files.first as Map;
    return (
      id: f['id'] as String,
      modified: DateTime.parse(f['modifiedTime'] as String).toLocal(),
    );
  }

  /// When the Drive copy was last written, or null if there is none.
  Future<DateTime?> lastBackup(String token) async =>
      (await _find(token))?.modified;

  /// Writes [json] as the single backup file, replacing the previous one.
  Future<void> upload(String token, String json) async {
    final existing = await _find(token);
    if (existing != null) {
      await _send(
        () => _http.patch(
          Uri.parse('$_upload/${existing.id}?uploadType=media'),
          headers: {..._auth(token), 'Content-Type': 'application/json'},
          body: utf8.encode(json),
        ),
      );
      return;
    }
    const boundary = 'nurday-backup-boundary';
    final body = [
      '--$boundary',
      'Content-Type: application/json; charset=UTF-8',
      '',
      jsonEncode({
        'name': driveFileName,
        'parents': ['appDataFolder'],
      }),
      '--$boundary',
      'Content-Type: application/json',
      '',
      json,
      '--$boundary--',
      '',
    ].join('\r\n');
    await _send(
      () => _http.post(
        Uri.parse('$_upload?uploadType=multipart'),
        headers: {
          ..._auth(token),
          'Content-Type': 'multipart/related; boundary=$boundary',
        },
        body: utf8.encode(body),
      ),
    );
  }

  /// The Drive copy, or null if there is none.
  Future<String?> download(String token) async {
    final f = await _find(token);
    if (f == null) return null;
    final res = await _send(
      () => _http.get(
        Uri.parse('$_api/${f.id}?alt=media'),
        headers: _auth(token),
      ),
    );
    return utf8.decode(res.bodyBytes);
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    final http.Response res;
    try {
      res = await call();
    } catch (_) {
      throw const DriveException(
        'Could not reach Google Drive. Check your connection.',
      );
    }
    if (res.statusCode == 401 || res.statusCode == 403) {
      throw const DriveException(
        'Google Drive access was refused. Connect again in Settings.',
      );
    }
    if (res.statusCode >= 300) {
      throw DriveException('Google Drive error ${res.statusCode}.');
    }
    return res;
  }
}

/// Backs the database up to Drive and restores it from there.
class DriveSync {
  DriveSync({
    required this.db,
    required this.auth,
    required this.drive,
    required this.now,
  });
  final AppDatabase db;
  final GoogleAuth auth;
  final DriveBackup drive;
  final DateTime Function() now;

  static const every = Duration(hours: 20);

  /// Asks for access (with a Google dialog if needed) and makes a first
  /// backup. Returns false if the user cancelled.
  Future<bool> connect() async {
    final token = await auth.token(prompt: true);
    if (token == null) return false;
    await _upload(token);
    await db.putSetting('driveBackup', 'true');
    return true;
  }

  Future<void> disconnect() async {
    await db.putSetting('driveBackup', 'false');
    await auth.signOut();
  }

  /// Backs up now. [prompt] false never shows a dialog and skips quietly if
  /// access would need one.
  Future<bool> backUp({bool prompt = true}) async {
    final token = await auth.token(prompt: prompt);
    if (token == null) return false;
    await _upload(token);
    return true;
  }

  /// The daily automatic backup: only when turned on and the last one is
  /// older than [every]. Never throws.
  Future<void> backUpIfDue(Map<String, String> settings) async {
    if (settings['driveBackup'] != 'true') return;
    final last = DateTime.tryParse(settings['driveLastBackup'] ?? '');
    if (last != null && now().difference(last) < every) return;
    try {
      await backUp(prompt: false);
    } catch (_) {}
  }

  /// Merges or replaces with the Drive copy. Null if there is no copy or the
  /// user cancelled.
  Future<ImportSummary?> restore(ImportMode mode) async {
    final token = await auth.token(prompt: true);
    if (token == null) return null;
    final json = await drive.download(token);
    if (json == null) return null;
    final keep = (await db.watchSettings().first).entries.where(
      (e) => e.key.startsWith('drive'),
    );
    final summary = await db.importJson(json, mode);
    // Keep this phone's Drive connection, whatever the backup says.
    for (final e in keep.toList()) {
      await db.putSetting(e.key, e.value);
    }
    return summary;
  }

  Future<void> _upload(String token) async {
    final t = now();
    await drive.upload(token, await db.exportJson(t));
    await db.putSetting('driveLastBackup', t.toIso8601String());
  }
}
