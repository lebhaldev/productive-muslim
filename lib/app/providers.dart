import 'dart:async';

import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../core/clock.dart';
import '../core/day_key.dart';
import '../data/app_lock.dart';
import '../data/backup_files.dart';
import '../data/content/content_models.dart';
import '../data/content/daily_content_service.dart';
import '../data/content/quran_client.dart';
import '../data/db/database.dart';
import '../data/drive_backup.dart';
import '../data/prayer/prayer.dart';
import '../data/reminders.dart';
import '../data/weather/weather.dart';
import 'theme.dart';

final clockProvider = Provider<Clock>((ref) => const Clock());

/// Overridden in main() and in tests.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError(),
);

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

final backupFilesProvider = Provider<BackupFiles>((ref) => const BackupFiles());

final googleAuthProvider = Provider<GoogleAuth>((ref) => GoogleSignInAuth());

final driveSyncProvider = Provider<DriveSync>(
  (ref) => DriveSync(
    db: ref.watch(databaseProvider),
    auth: ref.watch(googleAuthProvider),
    drive: DriveBackup(ref.watch(httpClientProvider)),
    now: ref.watch(clockProvider).now,
  ),
);

final appLockProvider = Provider<AppLock>((ref) => AppLock());

/// True once the user has unlocked the journal; cleared when the app goes to
/// the background.
class JournalUnlocked extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool v) => state = v;
}

final journalUnlockedProvider = NotifierProvider<JournalUnlocked, bool>(
  JournalUnlocked.new,
);

/// Whether journal text must be hidden right now.
final journalLockedProvider = Provider<bool>(
  (ref) =>
      (ref.watch(settingsProvider).value?.journalLock ?? false) &&
      !ref.watch(journalUnlockedProvider),
);

final assetLoaderProvider = Provider<AssetLoader>((ref) => rootBundleLoader);

/// Today's local day key; re-checked every minute so content rolls over at
/// local midnight (FR-2).
final todayProvider = StreamProvider<String>((ref) {
  final clock = ref.watch(clockProvider);
  final controller = StreamController<String>();
  var last = dayKey(clock.now());
  controller.add(last);
  final timer = Timer.periodic(const Duration(minutes: 1), (_) {
    final k = dayKey(clock.now());
    if (k != last) {
      last = k;
      controller.add(k);
    }
  });
  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });
  return controller.stream;
});

String todayKey(Ref ref) =>
    ref.watch(todayProvider).value ?? dayKey(ref.read(clockProvider).now());

final habitsProvider = StreamProvider<List<Habit>>(
  (ref) => ref.watch(databaseProvider).watchHabits(),
);

/// habitId → set of day keys with a completion.
final completionsProvider = StreamProvider<Map<int, Set<String>>>(
  (ref) => ref.watch(databaseProvider).watchCompletions().map((rows) {
    final m = <int, Set<String>>{};
    for (final r in rows) {
      (m[r.habitId] ??= <String>{}).add(r.dayKey);
    }
    return m;
  }),
);

final activitiesProvider = StreamProvider<List<Activity>>(
  (ref) => ref.watch(databaseProvider).watchActivities(),
);

/// dayKey → mood value 0..4
final moodsProvider = StreamProvider<Map<String, int>>(
  (ref) => ref
      .watch(databaseProvider)
      .watchMoods()
      .map((rows) => {for (final r in rows) r.dayKey: r.value}),
);

final journalsProvider = StreamProvider<Map<String, Journal>>(
  (ref) => ref
      .watch(databaseProvider)
      .watchJournals()
      .map((rows) => {for (final r in rows) r.dayKey: r}),
);

class AppSettings {
  const AppSettings(this.raw);
  final Map<String, String> raw;

  bool get showFaith => raw['faith'] != 'false';
  bool get fahrenheit => raw['unit'] == 'F';
  bool get journalLock => raw['journalLock'] == 'true';
  bool get driveBackup => raw['driveBackup'] == 'true';
  DateTime? get driveLastBackup =>
      DateTime.tryParse(raw['driveLastBackup'] ?? '');
  Translation get translation => Translation.parse(raw['translation']);
  String get city => raw['city'] ?? '';
  double? get lat => double.tryParse(raw['lat'] ?? '');
  double? get lon => double.tryParse(raw['lon'] ?? '');
  String get dailyReminder => raw['dailyReminder'] ?? '07:30';
  // Off until the user turns it on, so first launch shows no prompt.
  bool get dailyReminderOn => raw['dailyReminderOn'] == 'true';

  ColorTheme get colorTheme => ColorTheme.values.firstWhere(
    (t) => t.name == raw['colorTheme'],
    orElse: () => ColorTheme.sage,
  );

  ThemeMode get themeMode => switch (raw['themeMode']) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  /// Null until the user picks one; then the country default applies.
  PrayerMethod? get chosenPrayerMethod => raw['prayerMethod'] == null
      ? null
      : PrayerMethod.parse(raw['prayerMethod']);
  AsrMadhab get madhab => AsrMadhab.parse(raw['madhab']);
  HighLatitude get highLatitude => HighLatitude.parse(raw['highLatitude']);
  // Off by default, like the daily reminder.
  bool get prayerAlerts => raw['prayerAlerts'] == 'true';

  /// Content language: Arabic with the English translation, or Arabic only.
  bool get arabicOnly => raw['contentLanguage'] == 'ar';
}

final settingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(databaseProvider).watchSettings().map(AppSettings.new),
);

AppSettings settingsOf(WidgetRef ref) =>
    ref.watch(settingsProvider).value ?? const AppSettings({});

final contentServiceProvider = Provider<DailyContentService>(
  (ref) => DailyContentService(
    db: ref.watch(databaseProvider),
    quran: QuranClient(ref.watch(httpClientProvider)),
    loadAsset: ref.watch(assetLoaderProvider),
    now: ref.watch(clockProvider).now,
  ),
);

/// How many times the user tapped "Show another" per card, for one day.
class ContentOffsets extends Notifier<({String day, Map<String, int> n})> {
  @override
  ({String day, Map<String, int> n}) build() => (day: '', n: const {});

  void next(String day, String kind) {
    final n = state.day == day ? {...state.n} : <String, int>{};
    n[kind] = (n[kind] ?? 0) + 1;
    state = (day: day, n: n);
  }
}

final contentOffsetsProvider =
    NotifierProvider<ContentOffsets, ({String day, Map<String, int> n})>(
      ContentOffsets.new,
    );

final dailyContentProvider = FutureProvider<DailyContent>((ref) async {
  final day = todayKey(ref);
  final settings = await ref.watch(settingsProvider.future);
  final offsets = ref.watch(contentOffsetsProvider);
  return ref
      .watch(contentServiceProvider)
      .load(
        day,
        settings.translation,
        offsets: offsets.day == day ? offsets.n : const {},
      );
});

final tafsirProvider = FutureProvider.family<Tafsir?, String>(
  (ref, ayahRef) => ref.watch(contentServiceProvider).tafsirFor(ayahRef),
);

final weatherServiceProvider = Provider<WeatherService>(
  (ref) => WeatherService(
    ref.watch(httpClientProvider),
    ref.watch(databaseProvider),
    ref.watch(clockProvider).now,
  ),
);

final weatherProvider = FutureProvider<WeatherState>((ref) async {
  todayKey(ref);
  final s = await ref.watch(settingsProvider.future);
  return ref
      .watch(weatherServiceProvider)
      .load(city: s.city, lat: s.lat, lon: s.lon);
});

/// The day shown by Calendar and Journal (shared, as in the design).
class SelectedDay extends Notifier<String> {
  @override
  String build() => dayKey(ref.read(clockProvider).now());

  void set(String day) => state = day;
}

final selectedDayProvider = NotifierProvider<SelectedDay, String>(
  SelectedDay.new,
);

/// The activity being edited in the Activities form, if any.
class EditingActivity extends Notifier<Activity?> {
  @override
  Activity? build() => null;

  void set(Activity? a) => state = a;
}

final editingActivityProvider = NotifierProvider<EditingActivity, Activity?>(
  EditingActivity.new,
);

/// Today's day key for widgets.
String watchToday(WidgetRef ref) =>
    ref.watch(todayProvider).value ?? dayKey(ref.read(clockProvider).now());

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => LocalReminderScheduler(),
);

/// Ticks every minute, for countdowns.
final minuteProvider = StreamProvider<DateTime>((ref) {
  final clock = ref.watch(clockProvider);
  final controller = StreamController<DateTime>();
  controller.add(clock.now());
  final timer = Timer.periodic(
    const Duration(minutes: 1),
    (_) => controller.add(clock.now()),
  );
  ref.onDispose(() {
    timer.cancel();
    controller.close();
  });
  return controller.stream;
});

/// Where prayer times and Qibla are computed: "Use my location" if set,
/// otherwise the weather city (FR-12). Null until a location is known.
final prayerLocationProvider =
    Provider<({double lat, double lon, String place})?>((ref) {
      final s = ref.watch(settingsProvider).value;
      if (s == null) return null;
      if (s.lat != null && s.lon != null) {
        return (lat: s.lat!, lon: s.lon!, place: 'My location');
      }
      final w = ref.watch(weatherProvider).value?.weather;
      if (w?.lat == null || w?.lon == null) return null;
      return (lat: w!.lat!, lon: w.lon!, place: w.place);
    });

/// The chosen method, or the usual one for the weather city's country.
final prayerMethodProvider = Provider<PrayerMethod>((ref) {
  final s = ref.watch(settingsProvider).value;
  final chosen = s?.chosenPrayerMethod;
  if (chosen != null) return chosen;
  final w = ref.watch(weatherProvider).value?.weather;
  return PrayerMethod.forCountry(w?.countryCode);
});

/// Prayer times for [day] (a day key) at the prayer location.
final prayerDayProvider = Provider.family<PrayerDay?, String>((ref, day) {
  final loc = ref.watch(prayerLocationProvider);
  final s = ref.watch(settingsProvider).value;
  if (loc == null || s == null) return null;
  return prayerDay(
    lat: loc.lat,
    lon: loc.lon,
    date: parseDayKey(day),
    method: ref.watch(prayerMethodProvider),
    madhab: s.madhab,
    highLatitude: s.highLatitude,
  );
});

/// Reminders implied by the current settings and habits.
final reminderPlanProvider = Provider<List<Reminder>?>((ref) {
  final settings = ref.watch(settingsProvider).value;
  final habits = ref.watch(habitsProvider).value;
  if (settings == null || habits == null) return null;
  final today = todayKey(ref);
  final now = ref.read(clockProvider).now();
  final loc = ref.watch(prayerLocationProvider);
  final prayers = <({String name, DateTime at, String place})>[];
  if (settings.prayerAlerts && loc != null) {
    // One-off notifications for the next 7 days, rebuilt every day.
    for (var d = 0; d < 7; d++) {
      final times = ref.watch(prayerDayProvider(shiftDay(today, d)));
      if (times == null) break;
      for (final p in fivePrayers) {
        if (times[p].isAfter(now)) {
          prayers.add((name: prayerLabels[p]!, at: times[p], place: loc.place));
        }
      }
    }
  }
  return planReminders(
    dailyTime: settings.dailyReminderOn ? settings.dailyReminder : null,
    habits: [
      for (final h in habits)
        (id: h.id, name: h.name, time: h.reminderTime, archived: h.archived),
    ],
    prayers: prayers,
  );
});
