import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nurday/app/providers.dart';
import 'package:nurday/core/clock.dart';
import 'package:nurday/data/db/database.dart';
import 'package:nurday/data/app_lock.dart';
import 'package:nurday/data/drive_backup.dart';
import 'package:nurday/data/reminders.dart';

String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

/// Maps bundled asset paths to fixtures, so no real religious text is used.
Future<String> fixtureAssets(String path) async =>
    fixture(path.split('/').last);

AppDatabase memoryDb() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

/// Answers API calls with fixtures, or fails every call when [online] is false.
http.Client fakeHttp({bool online = true}) => MockClient((req) async {
  if (!online) throw const SocketException('offline');
  final host = req.url.host;
  if (host == 'api.alquran.cloud') {
    return http.Response.bytes(
      fixture(
        req.url.path.contains('editions')
            ? 'alquran_cloud_sahih.json'
            : 'alquran_cloud_uthmani.json',
      ).toUtf8(),
      200,
    );
  }
  if (host == 'api.quran.com') {
    return http.Response(fixture('quran_com_khattab.json'), 200);
  }
  if (host == 'geocoding-api.open-meteo.com') {
    return http.Response(fixture('open_meteo_geocoding.json'), 200);
  }
  if (host == 'api.open-meteo.com') {
    return http.Response(fixture('open_meteo_forecast.json'), 200);
  }
  return http.Response('not found', 404);
});

List<Override> testOverrides(
  AppDatabase db,
  DateTime now, {
  bool online = true,
  ReminderScheduler? scheduler,
  AppLock? lock,
  GoogleAuth? google,
}) => [
  googleAuthProvider.overrideWithValue(google ?? FakeAuth(granted: false)),
  appLockProvider.overrideWithValue(lock ?? FakeLock()),
  databaseProvider.overrideWithValue(db),
  reminderSchedulerProvider.overrideWithValue(scheduler ?? FakeScheduler()),
  clockProvider.overrideWithValue(FixedClock(now)),
  httpClientProvider.overrideWithValue(fakeHttp(online: online)),
  assetLoaderProvider.overrideWithValue(fixtureAssets),
  todayProvider.overrideWith(
    (ref) => Stream.value(
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
    ),
  ),
];

extension on String {
  List<int> toUtf8() => utf8.encode(this);
}

class FakeScheduler implements ReminderScheduler {
  FakeScheduler({this.granted = true});
  final bool granted;
  final synced = <List<Reminder>>[];
  @override
  Future<bool> requestPermission() async => granted;
  @override
  Future<void> sync(List<Reminder> plan) async => synced.add(plan);
}

class FakeLock implements AppLock {
  FakeLock({this.hasLock = true, this.accept = true});
  bool hasLock;
  bool accept;
  int asked = 0;
  @override
  Future<bool> available() async => hasLock;
  @override
  Future<bool> unlock(String reason) async {
    asked++;
    return accept;
  }
}

class FakeAuth implements GoogleAuth {
  FakeAuth({this.granted = true});
  bool granted;
  final prompts = <bool>[];
  bool signedOut = false;
  @override
  Future<String?> token({required bool prompt}) async {
    prompts.add(prompt);
    return granted ? 'tok' : null;
  }

  @override
  Future<void> signOut() async => signedOut = true;
}
