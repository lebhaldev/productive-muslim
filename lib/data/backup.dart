import 'dart:convert';

import 'package:drift/drift.dart';

import 'db/database.dart';

/// Nurday backup file: everything the user wrote, as one JSON document.
///
/// Caches (daily content, weather) are left out; they are refetched.
/// Format 2 adds the prayer log, excused days, duas, saved items and journal
/// gratitude lines. Format 1 files still import.
const backupFormat = 2;

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
    this.prayers = 0,
    this.duas = 0,
  });
  final int habits;
  final int completions;
  final int activities;
  final int moods;
  final int journals;
  final int prayers;
  final int duas;

  bool get isEmpty =>
      habits + completions + activities + moods + journals + prayers + duas ==
      0;

  @override
  String toString() {
    String n(int c, String one, String many) => '$c ${c == 1 ? one : many}';
    return [
      n(habits, 'habit', 'habits'),
      n(completions, 'habit check', 'habit checks'),
      n(activities, 'activity', 'activities'),
      n(moods, 'mood', 'moods'),
      n(journals, 'journal entry', 'journal entries'),
      if (prayers > 0) n(prayers, 'logged prayer', 'logged prayers'),
      if (duas > 0) n(duas, 'dua', 'duas'),
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
            'gratitude': j.gratitude == null ? null : jsonDecode(j.gratitude!),
          },
      ],
      'prayerLogs': [
        for (final l in await select(prayerLogs).get())
          {
            'dayKey': l.dayKey,
            'prayer': l.prayer,
            'loggedAt': l.loggedAt.toUtc().toIso8601String(),
          },
      ],
      'excusedDays': [
        for (final e in await select(excusedDays).get())
          {
            'dayKey': e.dayKey,
            'createdAt': e.createdAt.toUtc().toIso8601String(),
          },
      ],
      'duas': [
        for (final d in await select(duas).get())
          {
            'text': d.body,
            'note': d.note,
            'createdAt': d.createdAt.toUtc().toIso8601String(),
            'answeredAt': d.answeredAt?.toUtc().toIso8601String(),
            'sortOrder': d.sortOrder,
          },
      ],
      'bookmarks': [
        for (final b in await select(bookmarks).get())
          {
            'kind': b.kind,
            'ref': b.ref,
            'createdAt': b.createdAt.toUtc().toIso8601String(),
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
        await delete(prayerLogs).go();
        await delete(excusedDays).go();
        await delete(duas).go();
        await delete(bookmarks).go();
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

      // Logs, excused days and saved items: union, the phone's copy wins.
      final logged = {
        for (final l in await select(prayerLogs).get())
          '${l.dayKey}|${l.prayer}',
      };
      var newPrayers = 0;
      for (final l in b.prayerLogs) {
        if (!logged.add('${l.dayKey}|${l.prayer}')) continue;
        await into(prayerLogs).insert(l);
        newPrayers++;
      }
      for (final e in b.excusedDays) {
        await into(excusedDays).insert(e, mode: InsertMode.insertOrIgnore);
      }
      for (final k in b.bookmarks) {
        await into(bookmarks).insert(k, mode: InsertMode.insertOrIgnore);
      }

      // Duas: the same text written at the same moment is the same dua.
      final haveDuas = {
        for (final d in await select(duas).get())
          '${d.createdAt.toUtc().toIso8601String()}|${d.body}',
      };
      var newDuas = 0;
      for (final d in b.duas) {
        if (!haveDuas.add(
          '${d.createdAt.value.toUtc().toIso8601String()}|${d.body.value}',
        )) {
          continue;
        }
        await into(duas).insert(d);
        newDuas++;
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
        prayers: newPrayers,
        duas: newDuas,
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
  final prayerLogs = <PrayerLog>[];
  final excusedDays = <ExcusedDay>[];
  final duas = <DuasCompanion>[];
  final bookmarks = <Bookmark>[];
  final settings = <String, String>{};
}

const _prayers = {'fajr', 'dhuhr', 'asr', 'maghrib', 'isha'};

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

  /// Gratitude lines stored as JSON text, or null when there are none.
  String? gratitude(Map m) {
    final g = m['gratitude'];
    if (g == null) return null;
    if (g is! List || g.length > 3 || g.any((e) => e is! String)) {
      throw _damaged;
    }
    return jsonEncode(g);
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
        gratitude: gratitude(j),
      ),
    );
  }
  for (final l in list('prayerLogs')) {
    final prayer = field<String>(l, 'prayer');
    if (!_prayers.contains(prayer)) throw _damaged;
    p.prayerLogs.add(
      PrayerLog(dayKey: day(l), prayer: prayer, loggedAt: date(l, 'loggedAt')),
    );
  }
  for (final e in list('excusedDays')) {
    p.excusedDays.add(
      ExcusedDay(dayKey: day(e), createdAt: date(e, 'createdAt')),
    );
  }
  for (final d in list('duas')) {
    final answered = field<String?>(d, 'answeredAt');
    p.duas.add(
      DuasCompanion.insert(
        body: field<String>(d, 'text'),
        note: Value(field<String?>(d, 'note')),
        createdAt: date(d, 'createdAt'),
        answeredAt: Value(answered == null ? null : date(d, 'answeredAt')),
        sortOrder: Value(field<int?>(d, 'sortOrder') ?? 0),
      ),
    );
  }
  for (final k in list('bookmarks')) {
    final kind = field<String>(k, 'kind');
    if (kind != 'ayah' && kind != 'hadith') throw _damaged;
    p.bookmarks.add(
      Bookmark(
        kind: kind,
        ref: field<String>(k, 'ref'),
        createdAt: date(k, 'createdAt'),
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
