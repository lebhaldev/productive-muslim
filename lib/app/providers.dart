import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../core/clock.dart';
import '../core/day_key.dart';
import '../data/content/content_models.dart';
import '../data/content/daily_content_service.dart';
import '../data/content/quran_client.dart';
import '../data/db/database.dart';
import '../data/reminders.dart';
import '../data/weather/weather.dart';

final clockProvider = Provider<Clock>((ref) => const Clock());

/// Overridden in main() and in tests.
final databaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError(),
);

final httpClientProvider = Provider<http.Client>((ref) => http.Client());

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
  Translation get translation => Translation.parse(raw['translation']);
  String get city => raw['city'] ?? '';
  double? get lat => double.tryParse(raw['lat'] ?? '');
  double? get lon => double.tryParse(raw['lon'] ?? '');
  String get dailyReminder => raw['dailyReminder'] ?? '07:30';
  // Off until the user turns it on, so first launch shows no prompt.
  bool get dailyReminderOn => raw['dailyReminderOn'] == 'true';
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

final dailyContentProvider = FutureProvider<DailyContent>((ref) async {
  final day = todayKey(ref);
  final settings = await ref.watch(settingsProvider.future);
  return ref.watch(contentServiceProvider).load(day, settings.translation);
});

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

/// Reminders implied by the current settings and habits.
final reminderPlanProvider = Provider<List<Reminder>?>((ref) {
  final settings = ref.watch(settingsProvider).value;
  final habits = ref.watch(habitsProvider).value;
  if (settings == null || habits == null) return null;
  return planReminders(
    dailyTime: settings.dailyReminderOn ? settings.dailyReminder : null,
    habits: [
      for (final h in habits)
        (id: h.id, name: h.name, time: h.reminderTime, archived: h.archived),
    ],
  );
});
