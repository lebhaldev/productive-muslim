import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/data/db/database.dart';

import 'helpers.dart';

/// Opens a database that looks like one made by schema [version] on a phone,
/// using the CREATE statements saved in test/fixtures/schema.
AppDatabase oldDb(int version, List<String> inserts) => AppDatabase(
  NativeDatabase.memory(
    setup: (raw) {
      final sql = File('test/fixtures/schema/v$version.sql').readAsStringSync();
      for (final s in sql.split(';\n').where((s) => s.trim().isNotEmpty)) {
        raw.execute(s);
      }
      inserts.forEach(raw.execute);
      raw.execute('PRAGMA user_version = $version');
    },
  ),
);

Future<Map<String, List<String>>> columns(AppDatabase db) async {
  final tables = await db
      .customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'table' "
        "AND name NOT LIKE 'sqlite_%' ORDER BY name",
      )
      .get();
  return {
    for (final t in tables)
      t.read<String>('name'): [
        for (final c
            in await db
                .customSelect("PRAGMA table_info('${t.read<String>('name')}')")
                .get())
          '${c.read<String>('name')} ${c.read<String>('type')}',
      ]..sort(),
  };
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test(
    'a schema 1 database upgrades to the current schema and keeps data',
    () async {
      final db = oldDb(1, [
        "INSERT INTO habits (name) VALUES ('Read Quran')",
        "INSERT INTO habit_completions VALUES (1, '2026-10-01')",
        "INSERT INTO journals (day_key, title, body, created_at, updated_at) "
            "VALUES ('2026-10-01', 'T', 'Kept', 1, 1)",
        "INSERT INTO moods VALUES ('2026-10-01', 3, NULL, 1)",
        "INSERT INTO settings VALUES ('city', 'London')",
      ]);
      final fresh = memoryDb();
      expect(await columns(db), await columns(fresh));
      expect((await db.select(db.habits).getSingle()).name, 'Read Quran');
      expect(await db.select(db.habitCompletions).get(), hasLength(1));
      final j = await db.select(db.journals).getSingle();
      expect(j.body, 'Kept');
      expect(j.gratitude, isNull);
      expect(await db.select(db.moods).get(), hasLength(1));
      final settings = await db.watchSettings().first;
      expect(settings['city'], 'London');
      expect(settings['onboarded'], 'true', reason: 'no first run on upgrade');
      expect((await fresh.watchSettings().first)['onboarded'], isNull);
      // New tables work after the upgrade.
      await db.togglePrayer('2026-10-01', 'fajr', DateTime(2026, 10, 1, 6));
      await db.addDua('A dua', null, DateTime(2026, 10, 1));
      expect(await db.select(db.prayerLogs).get(), hasLength(1));
      expect(await db.select(db.duas).get(), hasLength(1));
      await db.close();
      await fresh.close();
    },
  );

  test(
    'a schema 2 database upgrades to schema 3 and keeps prayer logs and duas',
    () async {
      final db = oldDb(2, [
        "INSERT INTO habits (name) VALUES ('Read Quran')",
        "INSERT INTO prayer_logs VALUES ('2026-10-01', 'fajr', 1)",
        "INSERT INTO duas (text, created_at) VALUES ('Kept dua', 1)",
        "INSERT INTO settings VALUES ('onboarded', 'true')",
      ]);
      final fresh = memoryDb();
      expect(await columns(db), await columns(fresh));
      expect(await db.select(db.prayerLogs).get(), hasLength(1));
      expect((await db.select(db.duas).getSingle()).body, 'Kept dua');
      // The new tables work after the upgrade.
      final now = DateTime(2026, 11, 4, 8);
      await db.setQuranPages('2026-11-04', 6, now);
      await db.setFast('2026-11-04', 'fast', now);
      expect(await db.addDhikr('2026-11-04', 'subhanallah', 33), 33);
      expect((await db.watchQuranReads().first)['2026-11-04'], 6);
      expect((await db.watchFasts().first)['2026-11-04'], 'fast');
      await db.close();
      await fresh.close();
    },
  );
}
