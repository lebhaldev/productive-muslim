import 'dart:convert';

import 'package:drift/drift.dart';

import 'db/database.dart';

/// Nurday backup file: everything the user wrote, as one JSON document.
///
/// Caches (daily content, weather) are left out; they are refetched.
const backupFormat = 1;

class BackupException implements Exception {
  const BackupException(this.message);
  final String message;
  @override
  String toString() => message;
}

enum ImportMode { replace, merge }

class ImportSummary {
  const ImportSummary({
    required this.habits,
    required this.completions,
    required this.activities,
    required this.moods,
    required this.journals,
  });
  final int habits;
  final int completions;
  final int activities;
  final int moods;
  final int journals;

  bool get isEmpty => habits + completions + activities + moods + journals == 0;

  @override
  String toString() {
    String n(int c, String one, String many) => '$c ${c == 1 ? one : many}';
    return [
      n(habits, 'habit', 'habits'),
      n(completions, 'habit check', 'habit checks'),
      n(activities, 'activity', 'activities'),
      n(moods, 'mood', 'moods'),
      n(journals, 'journal entry', 'journal entries'),
    ].join(', ');
  }
}

/// File name for an export made on [now], e.g. `nurday-backup-2026-10-07.json`.
String backupFileName(DateTime now) =>
    'nurday-backup-${now.year}-${_two(now.month)}-${_two(now.day)}.json';

String _two(int n) => n.toString().padLeft(2, '0');

extension Backup on AppDatabase {
  Future<String> exportJson(DateTime now) async {
    final data = <String, Object?>{
      'app': 'nurday',
      'format': backupFormat,
      'exportedAt': now.toUtc().toIso8601String(),
      'habits': [
        for (final h in await select(habits).get())
          {
            'id': h.id,
            'name': h.name,
            'archived': h.archived,
            'sortOrder': h.sortOrder,
            'reminderTime': h.reminderTime,
            'createdAt': h.createdAt.toUtc().toIso8601String(),
          },
      ],
      'completions': [
        for (final c in await select(habitCompletions).get())
          {'habitId': c.habitId, 'dayKey': c.dayKey},
      ],
      'activities': [
        for (final a in await select(activities).get())
          {
            'title': a.title,
            'note': a.note,
            'startTime': a.startTime,
            'durationMinutes': a.durationMinutes,
            'dayKey': a.dayKey,
          },
      ],
      'moods': [
        for (final m in await select(moods).get())
          {
            'dayKey': m.dayKey,
            'value': m.value,
            'note': m.note,
            'updatedAt': m.updatedAt.toUtc().toIso8601String(),
          },
      ],
      'journals': [
        for (final j in await select(journals).get())
          {
            'dayKey': j.dayKey,
            'title': j.title,
            'body': j.body,
            'createdAt': j.createdAt.toUtc().toIso8601String(),
            'updatedAt': j.updatedAt.toUtc().toIso8601String(),
          },
      ],
      'settings': {
        for (final s in await select(settings).get()) s.key: s.value,
      },
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Reads a backup made by [exportJson].
  ///
  /// [ImportMode.replace] wipes the user's data first. [ImportMode.merge]
  /// keeps it: habits are matched by name, the newer mood or journal entry of
  /// a day wins, identical activities are skipped and existing settings stay.
  /// Throws [BackupException] before changing anything if the file is not a
  /// valid Nurday backup.
  Future<ImportSummary> importJson(String source, ImportMode mode) async {
    final b = _parse(source);
    return transaction(() async {
      if (mode == ImportMode.replace) {
        await delete(habitCompletions).go();
        await delete(habits).go();
        await delete(activities).go();
        await delete(moods).go();
        await delete(journals).go();
        await delete(settings).go();
      }

      // Habits: map the file's ids to ids in this database.
      final byName = {
        for (final h in await select(habits).get()) _norm(h.name): h.id,
      };
      final maxOrder = habits.sortOrder.max();
      var nextOrder =
          ((await (selectOnly(
                habits,
              )..addColumns([maxOrder])).getSingle()).read(maxOrder) ??
              -1) +
          1;
      final idMap = <int, int>{};
      var newHabits = 0;
      for (final h in b.habits) {
        final existing = byName[_norm(h.name)];
        if (existing != null) {
          idMap[h.id] = existing;
          continue;
        }
        final id = await into(habits).insert(
          HabitsCompanion.insert(
            name: h.name,
            archived: Value(h.archived),
            sortOrder: Value(
              mode == ImportMode.replace ? h.sortOrder : nextOrder++,
            ),
            reminderTime: Value(h.reminderTime),
            createdAt: Value(h.createdAt),
          ),
        );
        byName[_norm(h.name)] = id;
        idMap[h.id] = id;
        newHabits++;
      }

      final done = {
        for (final c in await select(habitCompletions).get())
          '${c.habitId}|${c.dayKey}',
      };
      var newCompletions = 0;
      for (final c in b.completions) {
        final id = idMap[c.habitId];
        if (id == null || !done.add('$id|${c.dayKey}')) continue;
        await into(habitCompletions).insert(
          HabitCompletionsCompanion.insert(habitId: id, dayKey: c.dayKey),
        );
        newCompletions++;
      }

      final seen = {
        for (final a in await select(activities).get())
          '${a.dayKey}|${a.startTime}|${a.title}',
      };
      var newActivities = 0;
      for (final a in b.activities) {
        if (!seen.add('${a.dayKey}|${a.startTime}|${a.title}')) continue;
        await into(activities).insert(
          ActivitiesCompanion.insert(
            title: a.title,
            note: Value(a.note),
            startTime: a.startTime,
            durationMinutes: a.durationMinutes,
            dayKey: a.dayKey,
          ),
        );
        newActivities++;
      }

      final localMoods = {
        for (final m in await select(moods).get()) m.dayKey: m.updatedAt,
      };
      var newMoods = 0;
      for (final m in b.moods) {
        final local = localMoods[m.dayKey];
        if (local != null && !m.updatedAt.isAfter(local)) continue;
        await into(moods).insertOnConflictUpdate(m);
        newMoods++;
      }

      final localJournals = {
        for (final j in await select(journals).get()) j.dayKey: j.updatedAt,
      };
      var newJournals = 0;
      for (final j in b.journals) {
        final local = localJournals[j.dayKey];
        if (local != null && !j.updatedAt.isAfter(local)) continue;
        await into(journals).insertOnConflictUpdate(j);
        newJournals++;
      }

      for (final e in b.settings.entries) {
        await into(settings).insert(
          SettingsCompanion.insert(key: e.key, value: e.value),
          mode: InsertMode.insertOrIgnore,
        );
      }

      return ImportSummary(
        habits: newHabits,
        completions: newCompletions,
        activities: newActivities,
        moods: newMoods,
        journals: newJournals,
      );
    });
  }
}

String _norm(String name) => name.trim().toLowerCase();

class _Parsed {
  final habits =
      <
        ({
          int id,
          String name,
          bool archived,
          int sortOrder,
          String? reminderTime,
          DateTime createdAt,
        })
      >[];
  final completions = <({int habitId, String dayKey})>[];
  final activities =
      <
        ({
          String title,
          String? note,
          String startTime,
          int durationMinutes,
          String dayKey,
        })
      >[];
  final moods = <Mood>[];
  final journals = <Journal>[];
  final settings = <String, String>{};
}

final _dayKey = RegExp(r'^\d{4}-\d{2}-\d{2}$');

const _damaged = BackupException(
  'This backup is damaged and was not imported.',
);

_Parsed _parse(String source) {
  const notBackup = BackupException('This file is not a Nurday backup.');
  Object? root;
  try {
    root = jsonDecode(source);
  } on FormatException {
    throw notBackup;
  }
  if (root is! Map || root['app'] != 'nurday') throw notBackup;
  final format = root['format'];
  if (format is! int) throw notBackup;
  if (format > backupFormat) {
    throw const BackupException(
      'This backup was made by a newer version of Nurday. Update the app, then try again.',
    );
  }

  T field<T>(Map m, String key) {
    final v = m[key];
    if (v is T) return v;
    throw _damaged;
  }

  List<Map> list(String key) {
    final v = root as Map;
    final l = v[key] ?? const [];
    if (l is! List || l.any((e) => e is! Map)) {
      throw _damaged;
    }
    return l.cast<Map>();
  }

  DateTime date(Map m, String key) {
    final d = DateTime.tryParse(field<String>(m, key));
    if (d == null) {
      throw _damaged;
    }
    return d.toLocal();
  }

  String day(Map m) {
    final d = field<String>(m, 'dayKey');
    if (!_dayKey.hasMatch(d)) {
      throw _damaged;
    }
    return d;
  }

  final p = _Parsed();
  for (final h in list('habits')) {
    p.habits.add((
      id: field<int>(h, 'id'),
      name: field<String>(h, 'name'),
      archived: field<bool>(h, 'archived'),
      sortOrder: field<int>(h, 'sortOrder'),
      reminderTime: field<String?>(h, 'reminderTime'),
      createdAt: date(h, 'createdAt'),
    ));
  }
  for (final c in list('completions')) {
    p.completions.add((habitId: field<int>(c, 'habitId'), dayKey: day(c)));
  }
  for (final a in list('activities')) {
    p.activities.add((
      title: field<String>(a, 'title'),
      note: field<String?>(a, 'note'),
      startTime: field<String>(a, 'startTime'),
      durationMinutes: field<int>(a, 'durationMinutes'),
      dayKey: day(a),
    ));
  }
  for (final m in list('moods')) {
    p.moods.add(
      Mood(
        dayKey: day(m),
        value: field<int>(m, 'value'),
        note: field<String?>(m, 'note'),
        updatedAt: date(m, 'updatedAt'),
      ),
    );
  }
  for (final j in list('journals')) {
    p.journals.add(
      Journal(
        dayKey: day(j),
        title: field<String>(j, 'title'),
        body: field<String>(j, 'body'),
        createdAt: date(j, 'createdAt'),
        updatedAt: date(j, 'updatedAt'),
      ),
    );
  }
  final s = root['settings'] ?? const {};
  if (s is! Map) {
    throw _damaged;
  }
  for (final e in s.entries) {
    if (e.key is String && e.value is String) {
      p.settings[e.key as String] = e.value as String;
    }
  }
  return p;
}
