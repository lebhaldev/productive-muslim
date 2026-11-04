import 'dart:async';
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
import 'package:nurday/data/content/recitation.dart';
import 'package:nurday/data/drive_backup.dart';
import 'package:nurday/data/home_widget_sync.dart';
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
    final path = req.url.path;
    final name = switch (path) {
      '/v1/edition' => 'alquran_cloud_reciters.json',
      '/v1/surah' => 'alquran_cloud_surahs.json',
      _ when path.startsWith('/v1/surah/') => 'alquran_cloud_surah_audio.json',
      _ when path.startsWith('/v1/ayah/') && path.contains('/ar.') =>
        'alquran_cloud_ayah_audio.json',
      _ when path.contains('editions') => 'alquran_cloud_sahih.json',
      _ => 'alquran_cloud_uthmani.json',
    };
    return http.Response.bytes(fixture(name).toUtf8(), 200);
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
  Future<String> Function(String path)? assets,
  http.Client? client,
  bool firstRun = false,
  HomeWidgetSink? homeWidget,
  RecitationPlayer? player,
}) => [
  firstRunEnabledProvider.overrideWithValue(firstRun),
  googleAuthProvider.overrideWithValue(google ?? FakeAuth(granted: false)),
  homeWidgetProvider.overrideWithValue(homeWidget ?? FakeHomeWidget()),
  recitationPlayerProvider.overrideWithValue(player ?? FakePlayer()),
  appLockProvider.overrideWithValue(lock ?? FakeLock()),
  databaseProvider.overrideWithValue(db),
  reminderSchedulerProvider.overrideWithValue(scheduler ?? FakeScheduler()),
  clockProvider.overrideWithValue(FixedClock(now)),
  httpClientProvider.overrideWithValue(client ?? fakeHttp(online: online)),
  assetLoaderProvider.overrideWithValue(assets ?? fixtureAssets),
  reverseGeocoderProvider.overrideWithValue(
    (lat, lon) async => (name: 'Fixture Town', countryCode: 'GB'),
  ),
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
  bool exact = false;
  int exactAsked = 0;
  int tests = 0;
  @override
  Future<bool> canExact() async => exact;
  @override
  Future<void> requestExact() async {
    exactAsked++;
    exact = true;
  }

  @override
  Future<void> test() async => tests++;
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

class FakeHomeWidget implements HomeWidgetSink {
  final writes = <Map<String, String>>[];
  @override
  Future<void> write(Map<String, String> data) async => writes.add(data);
}

class FakePlayer implements RecitationPlayer {
  final _c = StreamController<PlaybackState>.broadcast();
  PlaybackState _s = idlePlayback;
  List<String> urls = [];
  void _set(PlaybackState s) {
    _s = s;
    _c.add(s);
  }

  @override
  Stream<PlaybackState> get states => _c.stream;
  @override
  PlaybackState get state => _s;
  @override
  Future<void> play(String queueId, List<String> urls, {int start = 0}) async {
    this.urls = urls;
    _set((
      queueId: queueId,
      index: start,
      length: urls.length,
      playing: true,
      loading: false,
    ));
  }

  PlaybackState _with({int? index, bool? playing}) => (
    queueId: _s.queueId,
    index: index ?? _s.index,
    length: _s.length,
    playing: playing ?? _s.playing,
    loading: false,
  );
  @override
  Future<void> pause() async => _set(_with(playing: false));
  @override
  Future<void> resume() async => _set(_with(playing: true));
  @override
  Future<void> stop() async => _set(idlePlayback);
  @override
  Future<void> next() async =>
      _set(_with(index: (_s.index + 1).clamp(0, _s.length - 1)));
  @override
  Future<void> previous() async =>
      _set(_with(index: (_s.index - 1).clamp(0, _s.length - 1)));
}
