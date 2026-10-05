import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  TextColumn get reminderTime => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

class HabitCompletions extends Table {
  IntColumn get habitId =>
      integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  TextColumn get dayKey => text()();
  @override
  Set<Column> get primaryKey => {habitId, dayKey};
}

class Activities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  TextColumn get startTime => text()();
  IntColumn get durationMinutes => integer()();
  TextColumn get dayKey => text()();
}

class Moods extends Table {
  TextColumn get dayKey => text()();
  IntColumn get value => integer()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {dayKey};
}

class Journals extends Table {
  TextColumn get dayKey => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {dayKey};
}

class ContentCache extends Table {
  TextColumn get dayKey => text()();
  TextColumn get kind => text()();
  TextColumn get payload => text()();
  DateTimeColumn get fetchedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {dayKey, kind};
}

class WeatherCache extends Table {
  IntColumn get id => integer()();
  TextColumn get locationLabel => text()();
  TextColumn get payload => text()();
  DateTimeColumn get fetchedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    Habits,
    HabitCompletions,
    Activities,
    Moods,
    Journals,
    ContentCache,
    WeatherCache,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'nurday'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  // Habits

  Stream<List<Habit>> watchHabits() =>
      (select(habits)..orderBy([
            (h) => OrderingTerm.asc(h.sortOrder),
            (h) => OrderingTerm.asc(h.id),
          ]))
          .watch();

  Future<int> addHabit(String name) async {
    final max = habits.sortOrder.max();
    final row = await (selectOnly(habits)..addColumns([max])).getSingle();
    return into(habits).insert(
      HabitsCompanion.insert(
        name: name,
        sortOrder: Value((row.read(max) ?? -1) + 1),
      ),
    );
  }

  Future<void> setArchived(int id, bool archived) =>
      (update(habits)..where((h) => h.id.equals(id))).write(
        HabitsCompanion(archived: Value(archived)),
      );

  Future<void> setReminder(int id, String? time) =>
      (update(habits)..where((h) => h.id.equals(id))).write(
        HabitsCompanion(reminderTime: Value(time)),
      );

  Future<void> deleteHabit(int id) => transaction(() async {
    await (delete(habitCompletions)..where((c) => c.habitId.equals(id))).go();
    await (delete(habits)..where((h) => h.id.equals(id))).go();
  });

  /// Swaps [id] with the active habit above it.
  Future<void> moveUp(int id) => transaction(() async {
    final list =
        await (select(habits)
              ..where((h) => h.archived.equals(false))
              ..orderBy([
                (h) => OrderingTerm.asc(h.sortOrder),
                (h) => OrderingTerm.asc(h.id),
              ]))
            .get();
    final i = list.indexWhere((h) => h.id == id);
    if (i <= 0) return;
    for (var j = 0; j < list.length; j++) {
      final order = j == i ? i - 1 : (j == i - 1 ? i : j);
      await (update(habits)..where((h) => h.id.equals(list[j].id))).write(
        HabitsCompanion(sortOrder: Value(order)),
      );
    }
  });

  Stream<List<HabitCompletion>> watchCompletions() =>
      select(habitCompletions).watch();

  Future<void> toggleCompletion(int habitId, String day) =>
      transaction(() async {
        final q = delete(habitCompletions)
          ..where((c) => c.habitId.equals(habitId) & c.dayKey.equals(day));
        if (await q.go() == 0) {
          await into(habitCompletions).insert(
            HabitCompletionsCompanion.insert(habitId: habitId, dayKey: day),
          );
        }
      });

  // Activities

  Stream<List<Activity>> watchActivities() =>
      (select(activities)..orderBy([
            (a) => OrderingTerm.desc(a.dayKey),
            (a) => OrderingTerm.asc(a.startTime),
          ]))
          .watch();

  Future<void> saveActivity(ActivitiesCompanion a) =>
      into(activities).insertOnConflictUpdate(a);

  Future<void> deleteActivity(int id) =>
      (delete(activities)..where((a) => a.id.equals(id))).go();

  // Mood

  Stream<List<Mood>> watchMoods() => select(moods).watch();

  Future<void> setMood(String day, int value, DateTime now) => into(moods)
      .insertOnConflictUpdate(
        MoodsCompanion.insert(dayKey: day, value: value, updatedAt: now),
      );

  // Journal

  Stream<List<Journal>> watchJournals() => select(journals).watch();

  /// One entry per day (FR-3). An empty body removes the day's entry.
  Future<void> saveJournal(
    String day,
    String title,
    String body,
    DateTime now,
  ) async {
    if (body.trim().isEmpty) {
      await (delete(journals)..where((j) => j.dayKey.equals(day))).go();
      return;
    }
    final existing = await (select(
      journals,
    )..where((j) => j.dayKey.equals(day))).getSingleOrNull();
    await into(journals).insertOnConflictUpdate(
      JournalsCompanion.insert(
        dayKey: day,
        title: Value(title),
        body: body,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
      ),
    );
  }

  // Caches

  Future<ContentCacheData?> cachedContent(String day, String kind) =>
      (select(contentCache)
            ..where((c) => c.dayKey.equals(day) & c.kind.equals(kind)))
          .getSingleOrNull();

  Future<ContentCacheData?> latestContent(String kind) =>
      (select(contentCache)
            ..where((c) => c.kind.equals(kind))
            ..orderBy([(c) => OrderingTerm.desc(c.dayKey)])
            ..limit(1))
          .getSingleOrNull();

  Future<void> putContent(
    String day,
    String kind,
    String payload,
    DateTime now,
  ) => into(contentCache).insertOnConflictUpdate(
    ContentCacheCompanion.insert(
      dayKey: day,
      kind: kind,
      payload: payload,
      fetchedAt: now,
    ),
  );

  Future<WeatherCacheData?> cachedWeather() =>
      (select(weatherCache)..where((w) => w.id.equals(1))).getSingleOrNull();

  Future<void> putWeather(String label, String payload, DateTime now) =>
      into(weatherCache).insertOnConflictUpdate(
        WeatherCacheCompanion.insert(
          id: const Value(1),
          locationLabel: label,
          payload: payload,
          fetchedAt: now,
        ),
      );

  // Settings

  Stream<Map<String, String>> watchSettings() =>
      select(settings)
          .watch()
          .map((rows) => {for (final r in rows) r.key: r.value});

  Future<void> putSetting(String key, String value) => into(settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));
}
