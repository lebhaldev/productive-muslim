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
    FakeLock? lock,
    FakeAuth? google,
  }) async {
    final database = db ?? memoryDb();
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...testOverrides(
            database,
            now,
            online: online,
            lock: lock,
            google: google,
          ),
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

  /// Settings open from the gear on Today, then one section.
  Future<void> openSettings(WidgetTester tester, String section) async {
    await tapTab(tester, 'Today');
    await tester.tap(find.byKey(const Key('open-settings')));
    await settle(tester);
    await tester.tap(find.byKey(Key('settings-$section')));
    await settle(tester);
  }

  testWidgets(
    'Today shows the design sections with sourced content from fixtures',
    (tester) async {
      final db = memoryDb();
      await tester.runAsync(() => db.putSetting('city', 'London'));
      await pumpApp(tester, db: db);
      expect(find.text("Mon 5 Oct · 24 Rabi' Al-Thani 1448"), findsOneWidget);
      expect(find.text('Good morning'), findsOneWidget);
      expect(find.text('14°'), findsOneWidget);
      expect(find.text('Light cloud · London'), findsOneWidget);
      expect(find.text('NEXT PRAYER'), findsOneWidget);
      expect(find.text('London'), findsOneWidget);

      // Ayah, hadith and quote all show at once, no tabs.
      expect(find.text('AYAH OF THE DAY'), findsOneWidget);
      expect(find.text('HADITH OF THE DAY'), findsOneWidget);
      expect(find.text('QUOTE OF THE DAY'), findsOneWidget);
      expect(find.text('[ fixture arabic text ]'), findsOneWidget);
      expect(find.text('[ fixture translation text ]'), findsOneWidget);
      expect(
        find.text('Surah Ash-Sharh 94:5 · Saheeh International'),
        findsOneWidget,
      );
      // Tapping opens the published tafsir, copied from the dataset.
      await tester.tap(find.text('[ fixture translation text ]'));
      await settle(tester);
      expect(find.text('TAFSIR'), findsOneWidget);
      expect(find.text('[ fixture tafsir arabic ]'), findsOneWidget);
      expect(find.text('[ fixture tafsir english ]'), findsOneWidget);
      expect(find.text('Fixture Tafsir EN · Fixture Center'), findsOneWidget);

      // Hadith in Arabic from the dataset, with the English below (CR-7).
      await scrollTo(tester, find.text('[ fixture hadith text ]'));
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -250));
      await settle(tester);
      expect(find.text('[ fixture hadith arabic ]'), findsOneWidget);
      expect(find.text('[ fixture hadith text ]'), findsOneWidget);
      expect(find.text('Sahih al-Bukhari · Book 2 · No. 13'), findsOneWidget);
      // Opened: reference and no made-up explanation or grading (CR-1, CR-4).
      await tester.tap(find.text('[ fixture hadith text ]'));
      await settle(tester);
      expect(
        find.text(
          'Belief · English: Fixture Translator · https://sunnah.com/bukhari:13',
        ),
        findsOneWidget,
      );
      expect(
        find.text('No reviewed explanation is available for this hadith yet.'),
        findsOneWidget,
      );
      expect(find.textContaining('Grading'), findsNothing);
      expect(find.textContaining('App summary'), findsNothing);

      await scrollTo(tester, find.byKey(const Key('content-next-quote')));
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -250));
      await settle(tester);
      expect(find.text('Fixture Author · Fixture work'), findsOneWidget);
      final first = find.text('[ fixture arabic quote ]').evaluate().isEmpty
          ? '[ second fixture quote ]'
          : '[ fixture arabic quote ]';
      // "Show another" moves to the next quote of the pool.
      await tester.tap(find.byKey(const Key('content-next-quote')));
      await settle(tester);
      expect(find.text(first), findsNothing);
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
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -250));
      await settle(tester);
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
      await scrollTo(tester, find.byKey(const Key('activity-tile')));
      await tester.tap(find.byKey(const Key('activity-tile')));
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
      await scrollTo(tester, find.byKey(const Key('journal-tile')));
      await tester.tap(find.byKey(const Key('journal-tile')));
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
    expect(find.byKey(const Key('content-card-ayah')), findsNothing);
    expect(find.byKey(const Key('content-card-quote')), findsNothing);
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

      await openSettings(tester, 'reminders');
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
    expect(find.text('[ fixture arabic text ]'), findsOneWidget);
    expect(find.text('[ fixture translation text ]'), findsNothing);
    await scrollTo(tester, find.text('[ fixture hadith arabic ]'));
    expect(find.text('[ fixture hadith text ]'), findsNothing);
    await closeApp(tester, db);
  });

  testWidgets('dark theme can be chosen in Settings', (tester) async {
    final db = await pumpApp(tester);
    expect(
      Theme.of(tester.element(find.text('Good morning'))).brightness,
      Brightness.light,
    );
    await openSettings(tester, 'appearance');
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

  testWidgets('a locked journal hides its text until unlocked', (tester) async {
    final lock = FakeLock(accept: false);
    final db = memoryDb();
    await tester.runAsync(() async {
      await db.saveJournal('2026-10-05', 'Private', 'Secret words', now);
      await db.putSetting('journalLock', 'true');
    });
    await pumpApp(tester, db: db, lock: lock);
    await scrollTo(tester, find.text('Written today · locked'));
    expect(find.text('Private'), findsNothing);

    await tapTab(tester, 'Calendar');
    expect(find.textContaining('Secret words'), findsNothing);

    await tapTab(tester, 'Journal');
    expect(find.text('Your journal is locked'), findsOneWidget);
    expect(find.text('Secret words'), findsNothing);
    await tester.tap(find.byKey(const Key('unlock-journal')));
    await settle(tester);
    expect(find.text('Not unlocked. Try again.'), findsOneWidget);

    lock.accept = true;
    await tester.tap(find.byKey(const Key('unlock-journal')));
    await settle(tester);
    expect(find.text('Secret words'), findsOneWidget);
    await closeApp(tester, db);
  });

  testWidgets('the journal lock needs a phone screen lock', (tester) async {
    final lock = FakeLock(hasLock: false);
    final db = await pumpApp(tester, lock: lock);
    await openSettings(tester, 'privacy');
    final sw = find.byKey(const Key('journal-lock-switch'));
    await scrollTo(tester, sw);
    await tester.ensureVisible(sw);
    await settle(tester);
    await tester.tap(sw);
    await settle(tester);
    expect(find.textContaining('Set up a screen lock'), findsOneWidget);
    expect(tester.widget<SwitchListTile>(sw).value, isFalse);

    lock.hasLock = true;
    await tester.tap(sw);
    await settle(tester);
    expect(tester.widget<SwitchListTile>(sw).value, isTrue);
    expect(lock.asked, 1);
    await closeApp(tester, db);
  });

  testWidgets('Google Drive connect reports cancel and errors', (tester) async {
    final google = FakeAuth(granted: false);
    final db = await pumpApp(tester, google: google);
    await openSettings(tester, 'backup');
    final connect = find.byKey(const Key('drive-connect'));
    await scrollTo(tester, connect);
    await tester.ensureVisible(connect);
    await settle(tester);
    await tester.tap(connect);
    await settle(tester);
    expect(google.prompts, [true]);
    expect(find.byKey(const Key('drive-backup-now')), findsNothing);

    // The test network has no Drive, so the first backup fails visibly.
    google.granted = true;
    await tester.tap(connect);
    await settle(tester);
    expect(find.text('Google Drive error 404.'), findsOneWidget);
    await closeApp(tester, db);
  });

  testWidgets('colour themes can be picked in Settings', (tester) async {
    final db = await pumpApp(tester);
    await openSettings(tester, 'appearance');
    await scrollTo(tester, find.byKey(const Key('color-theme-ocean')));
    await tester.tap(find.byKey(const Key('color-theme-ocean')));
    await settle(tester);
    expect(AppColors.current, Palette.oceanLight);

    await tester.tap(find.byKey(const Key('color-theme-night')));
    await settle(tester);
    expect(AppColors.current, Palette.night);
    expect(
      Theme.of(tester.element(find.text('Night'))).brightness,
      Brightness.dark,
    );
    expect(
      find.text('Night is always dark, for OLED screens.'),
      findsOneWidget,
    );
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
    await openSettings(tester, 'backup');
    await scrollTo(tester, find.byKey(const Key('export-backup')));
    await tester.ensureVisible(find.byKey(const Key('import-backup')));
    await settle(tester);
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
