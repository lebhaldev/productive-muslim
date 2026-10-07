import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/app/app.dart';
import 'package:nurday/app/providers.dart';
import 'package:nurday/app/theme.dart';
import 'package:nurday/data/backup_files.dart';
import 'package:nurday/data/db/database.dart';

import '../helpers.dart';

/// Pumps enough frames for drift streams and fixture HTTP calls to land.
/// (pumpAndSettle can spin on drift's stream timers.)
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 15; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> scrollTo(WidgetTester tester, Finder finder) => tester
    .scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first);

void main() {
  final now = DateTime(2026, 10, 5, 7, 12);

  Future<AppDatabase> pumpApp(
    WidgetTester tester, {
    AppDatabase? db,
    bool online = true,
    BackupFiles? files,
  }) async {
    final database = db ?? memoryDb();
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...testOverrides(database, now, online: online),
          if (files != null) backupFilesProvider.overrideWithValue(files),
        ],
        child: const NurdayApp(),
      ),
    );
    await settle(tester);
    return database;
  }

  Future<void> closeApp(WidgetTester tester, AppDatabase db) async {
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    // Drift needs real async to close its connection.
    await tester.runAsync(db.close);
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(find.byKey(Key('tab-$label')));
    await settle(tester);
  }

  testWidgets(
    'Today shows the design sections with sourced content from fixtures',
    (tester) async {
      final db = memoryDb();
      await tester.runAsync(() => db.putSetting('city', 'London'));
      await pumpApp(tester, db: db);
      expect(find.text('Monday 5 October'), findsOneWidget);
      expect(find.text('Good morning'), findsOneWidget);
      expect(find.text('14°'), findsOneWidget);
      expect(find.text('Light cloud · London'), findsOneWidget);
      expect(find.text('H 18° · L 9°'), findsOneWidget);
      expect(find.text('AYAH OF THE DAY'), findsOneWidget);
      expect(find.text('[ fixture arabic text ]'), findsOneWidget);
      expect(find.text('[ fixture translation text ]'), findsOneWidget);
      expect(
        find.text('Surah Ash-Sharh 94:5 · Saheeh International'),
        findsOneWidget,
      );
      // Hijri date under the Gregorian one, prayer card from the city.
      expect(find.text("24 Rabi' Al-Thani 1448"), findsOneWidget);
      expect(find.text('NEXT PRAYER'), findsOneWidget);
      expect(find.text('London'), findsOneWidget);
      // Hadith in Arabic from the dataset, with the English below (CR-7).
      await scrollTo(tester, find.text('[ fixture hadith text ]'));
      // Lift the card clear of the bottom navigation bar before tapping it.
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -250));
      await settle(tester);
      expect(find.text('[ fixture hadith arabic ]'), findsOneWidget);
      expect(find.text('Sahih al-Bukhari · Book 2 · No. 13'), findsOneWidget);
      // Expanded: reference only, no made-up grading or summary (CR-1, CR-4).
      await tester.tap(find.text('[ fixture hadith text ]'));
      await settle(tester);
      expect(
        find.text(
          'Belief · English: Fixture Translator · https://sunnah.com/bukhari:13',
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Grading'), findsNothing);
      expect(find.textContaining('App summary'), findsNothing);
      expect(find.text('Fixture Author · Fixture work'), findsOneWidget);
      expect(find.text('[ fixture arabic quote ]'), findsOneWidget);
      await closeApp(tester, db);
    },
  );

  testWidgets(
    'log habit, mood, activity and journal, then see them on the calendar day',
    (tester) async {
      final db = await pumpApp(tester);

      // Habit
      await tapTab(tester, 'Habits');
      await tester.enterText(find.byType(TextField).first, 'Morning walk');
      await tester.tap(find.text('Add'));
      await settle(tester);
      expect(find.text('Start today'), findsOneWidget);

      await tapTab(tester, 'Today');
      await scrollTo(tester, find.text('Morning walk'));
      expect(find.text('0 of 1'), findsOneWidget);
      await tester.tap(find.text('Morning walk'));
      await settle(tester);
      expect(find.text('All done today'), findsOneWidget);
      expect(find.text('1 day'), findsOneWidget);

      // Mood
      await scrollTo(tester, find.text('good'));
      await tester.tap(find.text('good'));
      await settle(tester);

      // Activity via + Log
      await scrollTo(tester, find.text('+ Log'));
      await tester.tap(find.text('+ Log'));
      await settle(tester);
      await tester.enterText(
        find.byKey(const Key('activity-title')),
        'Fajr walk by the river',
      );
      await tester.pump();
      await tester.tap(find.text('Log activity'));
      await settle(tester);
      expect(find.text('Fajr walk by the river'), findsOneWidget);

      // Journal via Today shortcut
      await tapTab(tester, 'Today');
      await scrollTo(tester, find.text('Write today’s journal'));
      await tester.tap(find.text('Write today’s journal'));
      await settle(tester);
      await tester.enterText(
        find.byKey(const Key('journal-body')),
        'Quiet and good.',
      );
      await tester.pump(const Duration(milliseconds: 500));
      await settle(tester);
      expect(find.textContaining('Saved on this phone'), findsOneWidget);

      // Calendar day detail
      await tapTab(tester, 'Calendar');
      expect(find.text('October 2026'), findsOneWidget);
      await scrollTo(
        tester,
        find.text('07:12  Fajr walk by the river · 30 min'),
      );
      expect(find.text('Quiet and good.'), findsOneWidget);
      expect(find.text('good'), findsWidgets);
      expect(find.text('Morning walk'), findsOneWidget);
      expect(
        find.text('07:12  Fajr walk by the river · 30 min'),
        findsOneWidget,
      );

      await closeApp(tester, db);
    },
  );

  testWidgets('data survives an app restart with no network', (tester) async {
    final db = memoryDb();
    await tester.runAsync(() async {
      await db.addHabit('Read Quran 10 min');
      await db.saveJournal('2026-10-05', '', 'Offline entry', now);
      await db.setMood('2026-10-05', 4, now);
    });

    await pumpApp(tester, db: db, online: false);
    await scrollTo(tester, find.text('Read Quran 10 min'));
    expect(find.text('Read Quran 10 min'), findsOneWidget);
    // No cached ayah and no network: the failed source is named, nothing invented.
    expect(
      find.textContaining('AlQuran Cloud could not be reached'),
      findsOneWidget,
    );
    await tapTab(tester, 'Calendar');
    await scrollTo(tester, find.text('Offline entry'));
    expect(find.text('Offline entry'), findsOneWidget);
    expect(find.text('bright'), findsOneWidget);
    await closeApp(tester, db);
  });

  testWidgets('hiding faith cards removes them from Today', (tester) async {
    final db = memoryDb();
    await tester.runAsync(() => db.putSetting('faith', 'false'));
    await pumpApp(tester, db: db);
    expect(find.text('AYAH OF THE DAY'), findsNothing);
    expect(find.text('HADITH OF THE DAY'), findsNothing);
    expect(find.text('Habits'), findsWidgets);
    await closeApp(tester, db);
  });

  testWidgets(
    'offline with an older cached ayah says it is the last saved one',
    (tester) async {
      final db = memoryDb();
      await tester.runAsync(
        () => db.putContent(
          '2026-10-03',
          'ayah:sahih',
          '{"ref":"94:5","surahName":"Ash-Sharh","arabic":"[ fixture arabic text ]",'
              '"translation":"[ fixture translation text ]","translator":"Saheeh International",'
              '"edition":"quran-uthmani + en.sahih","sourceUrl":"https://quran.com/94/5"}',
          DateTime(2026, 10, 3, 6, 58),
        ),
      );
      await pumpApp(tester, db: db, online: false);
      expect(find.text('[ fixture translation text ]'), findsOneWidget);
      expect(find.text('Last saved ayah · 3 Oct'), findsOneWidget);
      await closeApp(tester, db);
    },
  );

  testWidgets(
    'daily reminder starts off and turning it on asks permission; denial flips it back',
    (tester) async {
      final db = memoryDb();
      final denied = FakeScheduler(granted: false);
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: testOverrides(db, now, scheduler: denied),
          child: const NurdayApp(),
        ),
      );
      await settle(tester);
      // First launch: nothing scheduled, so no permission prompt.
      expect(denied.synced.single, isEmpty);

      await tapTab(tester, 'More');
      await tester.tap(find.text('Settings'));
      await settle(tester);
      await scrollTo(tester, find.byKey(const Key('daily-reminder-switch')));
      await tester.ensureVisible(
        find.byKey(const Key('daily-reminder-switch')),
      );
      await settle(tester);
      await tester.tap(find.byKey(const Key('daily-reminder-switch')));
      await settle(tester);
      expect(
        find.textContaining('Notifications are off for Nurday'),
        findsOneWidget,
      );
      expect(
        tester
            .widget<Switch>(find.byKey(const Key('daily-reminder-switch')))
            .value,
        isFalse,
      );
      await closeApp(tester, db);
    },
  );

  testWidgets('Arabic only hides the English under ayah and hadith', (
    tester,
  ) async {
    final db = memoryDb();
    await tester.runAsync(() => db.putSetting('contentLanguage', 'ar'));
    await pumpApp(tester, db: db);
    await scrollTo(tester, find.text('[ fixture hadith arabic ]'));
    expect(find.text('[ fixture arabic text ]'), findsOneWidget);
    expect(find.text('[ fixture translation text ]'), findsNothing);
    expect(find.text('[ fixture hadith text ]'), findsNothing);
    await closeApp(tester, db);
  });

  testWidgets('dark theme can be chosen in Settings', (tester) async {
    final db = await pumpApp(tester);
    expect(
      Theme.of(tester.element(find.text('Good morning'))).brightness,
      Brightness.light,
    );
    await tapTab(tester, 'More');
    await tester.tap(find.text('Settings'));
    await settle(tester);
    await scrollTo(tester, find.text('Dark'));
    await tester.tap(find.text('Dark'));
    await settle(tester);
    expect(
      Theme.of(tester.element(find.text('Dark'))).brightness,
      Brightness.dark,
    );
    expect(AppColors.current, Palette.dark);
    await closeApp(tester, db);
    AppColors.current = Palette.light;
  });

  testWidgets('Prayer times screen shows the six times and Qibla', (
    tester,
  ) async {
    final db = memoryDb();
    await tester.runAsync(() => db.putSetting('city', 'London'));
    await pumpApp(tester, db: db);
    await tapTab(tester, 'More');
    await tester.tap(find.text('Prayer times'));
    await settle(tester);
    for (final p in ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']) {
      expect(find.text(p), findsOneWidget);
    }
    expect(find.textContaining('Muslim World League'), findsOneWidget);
    await scrollTo(tester, find.text('QIBLA'));
    expect(find.textContaining('° from true North'), findsOneWidget);
    await closeApp(tester, db);
  });

  testWidgets('without a location the prayer card asks for a city', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    expect(
      find.text('Set your city in Settings to see prayer times.'),
      findsOneWidget,
    );
    await closeApp(tester, db);
  });

  testWidgets('a backup exported in Settings can be imported again', (
    tester,
  ) async {
    final files = FakeBackupFiles();
    final db = memoryDb();
    await tester.runAsync(() async {
      await db.addHabit('Walk');
      await db.saveJournal('2026-10-05', 'Day', 'Alhamdulillah', now);
    });
    await pumpApp(tester, db: db, files: files);
    await tapTab(tester, 'More');
    await tester.tap(find.text('Settings'));
    await settle(tester);
    await scrollTo(tester, find.byKey(const Key('export-backup')));
    await tester.tap(find.byKey(const Key('export-backup')));
    await settle(tester);
    expect(find.text('Backup saved.'), findsOneWidget);
    expect(files.saved.keys.single, 'nurday-backup-2026-10-05.json');

    // Importing into the same phone finds nothing new.
    files.toOpen = files.saved.values.single;
    await tester.tap(find.byKey(const Key('import-backup')));
    await settle(tester);
    await tester.tap(find.text('Merge'));
    await settle(tester);
    expect(find.text('Nothing new in this backup.'), findsOneWidget);

    files.toOpen = 'hello';
    await tester.tap(find.byKey(const Key('import-backup')));
    await settle(tester);
    await tester.tap(find.text('Merge'));
    await settle(tester);
    expect(find.text('This file is not a Nurday backup.'), findsOneWidget);
    await closeApp(tester, db);
  });
}

class FakeBackupFiles implements BackupFiles {
  final saved = <String, String>{};
  String? toOpen;
  @override
  Future<bool> save(String fileName, String contents) async {
    saved[fileName] = contents;
    return true;
  }

  @override
  Future<String?> open() async => toOpen;
}
