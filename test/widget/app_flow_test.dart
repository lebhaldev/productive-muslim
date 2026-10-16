import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nurday/app/app.dart';
import 'package:nurday/app/providers.dart';
import 'package:nurday/app/theme.dart';
import 'package:nurday/core/day_key.dart';
import 'package:nurday/features/journal/journal_screen.dart';
import 'package:nurday/features/today/mood_week.dart';
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
    FakeScheduler? scheduler,
    Future<String> Function(String path)? assets,
    bool firstRun = false,
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
            scheduler: scheduler,
            assets: assets,
            firstRun: firstRun,
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
      // One segment for the habit and five for the prayers (FR-17).
      expect(find.text('0 of 6 today'), findsOneWidget);
      await tester.tap(find.text('Morning walk'));
      await settle(tester);
      expect(find.text('1 of 6 today'), findsOneWidget);
      expect(find.text('1 of 7 days'), findsOneWidget);

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
    for (final p in ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha']) {
      expect(find.byKey(Key('prayer-row-$p')), findsOneWidget);
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

  testWidgets('font and Arabic font can be chosen in Appearance', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await openSettings(tester, 'appearance');
    await scrollTo(tester, find.byKey(const Key('app-font')));
    await tester.tap(find.byKey(const Key('app-font')));
    await settle(tester);
    await tester.tap(find.text('Rounded').last);
    await settle(tester);
    expect(AppFonts.current, AppFont.rounded);
    await scrollTo(tester, find.byKey(const Key('arabic-font')));
    await tester.tap(find.byKey(const Key('arabic-font')));
    await settle(tester);
    await tester.tap(find.text('Noto Naskh Arabic').last);
    await settle(tester);
    expect(AppFonts.arabic, ArabicFont.naskh);
    await closeApp(tester, db);
    AppFonts.current = AppFont.classic;
    AppFonts.arabic = ArabicFont.amiri;
  });

  testWidgets('every colour theme can be picked', (tester) async {
    final db = await pumpApp(tester);
    await openSettings(tester, 'appearance');
    for (final t in [ColorTheme.lavender, ColorTheme.mono]) {
      await scrollTo(tester, find.byKey(Key('color-theme-${t.name}')));
      await tester.tap(find.byKey(Key('color-theme-${t.name}')));
      await settle(tester);
      expect(AppColors.current, t.light);
    }
    await closeApp(tester, db);
    AppColors.current = Palette.light;
  });

  testWidgets('city search suggests places and picking one names the weather', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await openSettings(tester, 'location');
    await tester.enterText(find.byKey(const Key('city-search')), 'Lond');
    await tester.pump(const Duration(milliseconds: 400));
    await settle(tester);
    expect(find.text('London'), findsOneWidget);
    expect(find.text('United Kingdom'), findsOneWidget);
    await tester.tap(find.text('London'));
    await settle(tester);
    expect(find.text('Current place: London'), findsOneWidget);
    final s = await tester.runAsync(() => db.select(db.settings).get());
    final m = {for (final r in s!) r.key: r.value};
    expect(m['placeName'], 'London');
    expect(m['lat'], '51.5085');
    GoRouter.of(tester.element(find.byKey(const Key('city-search'))))
        .go('/today');
    await settle(tester);
    expect(find.text('Light cloud · London'), findsOneWidget);
    await closeApp(tester, db);
  });

  testWidgets('a saved location without a name gets one from the geocoder', (
    tester,
  ) async {
    final db = memoryDb();
    await tester.runAsync(() async {
      await db.putSetting('lat', '51.51');
      await db.putSetting('lon', '-0.13');
    });
    await pumpApp(tester, db: db);
    expect(find.text('Light cloud · Fixture Town'), findsOneWidget);
    await closeApp(tester, db);
  });

  testWidgets('prayer alerts can ask for on-time alarms and send a test', (
    tester,
  ) async {
    final db = memoryDb();
    await tester.runAsync(() => db.putSetting('prayerAlerts', 'true'));
    final sched = FakeScheduler();
    await pumpApp(tester, db: db, scheduler: sched);
    await openSettings(tester, 'prayer');
    await scrollTo(tester, find.byKey(const Key('allow-exact')));
    await tester.tap(find.byKey(const Key('allow-exact')));
    await settle(tester);
    expect(sched.exactAsked, 1);
    expect(find.byKey(const Key('allow-exact')), findsNothing);
    await scrollTo(tester, find.byKey(const Key('test-notification')));
    await tester.tap(find.byKey(const Key('test-notification')));
    await settle(tester);
    expect(sched.tests, 1);
    expect(find.text('Test notification sent.'), findsOneWidget);
    await closeApp(tester, db);
  });

  testWidgets('Hijri offset and mosque minute adjustments are saved', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await openSettings(tester, 'prayer');
    await scrollTo(tester, find.byKey(const Key('hijri-offset')));
    await tester.tap(find.byKey(const Key('hijri-offset')));
    await settle(tester);
    await tester.tap(find.text('1 day later').last);
    await settle(tester);
    await scrollTo(tester, find.byKey(const Key('prayer-adjust')));
    await tester.tap(find.byKey(const Key('prayer-adjust')));
    await settle(tester);
    await scrollTo(tester, find.byKey(const Key('adjust-plus-maghrib')));
    await tester.tap(find.byKey(const Key('adjust-plus-maghrib')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('adjust-plus-maghrib')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('adjust-minus-fajr')));
    await settle(tester);
    expect(find.text('+2 min'), findsOneWidget);
    expect(find.text('−1 min'), findsOneWidget);
    final rows = await tester.runAsync(() => db.select(db.settings).get());
    final m = {for (final r in rows!) r.key: r.value};
    expect(m['hijriOffset'], '1');
    expect(m['adjust_maghrib'], '2');
    expect(m['adjust_fajr'], '-1');
    await closeApp(tester, db);
  });

  testWidgets('prayers are logged from the arc, with Undo, and shown as Done', (
    tester,
  ) async {
    final db = memoryDb();
    await tester.runAsync(() => db.putSetting('city', 'London'));
    await pumpApp(tester, db: db);
    // 07:12 in London: Fajr has started, Dhuhr has not.
    await scrollTo(tester, find.byKey(const Key('arc-fajr')));
    await tester.tap(find.byKey(const Key('arc-fajr')));
    await settle(tester);
    expect(find.text('Fajr logged'), findsOneWidget);
    var logs = await tester.runAsync(() => db.select(db.prayerLogs).get());
    expect(logs!.single.prayer, 'fajr');
    await tester.tap(find.text('Undo'));
    await settle(tester);
    logs = await tester.runAsync(() => db.select(db.prayerLogs).get());
    expect(logs, isEmpty);
    await tester.ensureVisible(find.byKey(const Key('arc-dhuhr')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('arc-dhuhr')), warnIfMissed: false);
    await settle(tester);
    logs = await tester.runAsync(() => db.select(db.prayerLogs).get());
    expect(
      logs,
      isEmpty,
      reason: 'a prayer that has not started cannot be logged',
    );

    await tester.tap(find.byKey(const Key('arc-fajr')));
    await settle(tester);
    GoRouter.of(tester.element(find.byType(Scaffold).last)).go('/more/prayer');
    await settle(tester);
    expect(
      find.descendant(
        of: find.byKey(const Key('prayer-row-fajr')),
        matching: find.text('Done'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('prayer-row-dhuhr')),
        matching: find.textContaining('Next · in'),
      ),
      findsOneWidget,
    );
    await closeApp(tester, db);
  });

  testWidgets('an excused day leaves consistency counts and can be undone', (
    tester,
  ) async {
    final db = memoryDb();
    final today = dayKey(now);
    await tester.runAsync(() async {
      final id = await db.addHabit('Read Quran');
      await db.toggleCompletion(id, shiftDay(today, -1));
      await db.toggleCompletion(id, shiftDay(today, -2));
    });
    await pumpApp(tester, db: db);
    await scrollTo(tester, find.byKey(const Key('excused-today')));
    expect(find.text('2 of 7 days'), findsOneWidget);
    expect(find.byKey(const Key('today-bar')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('excused-today')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('excused-today')));
    await settle(tester);
    expect(find.text('Count today again'), findsOneWidget);
    expect(find.text('Excused today'), findsOneWidget, reason: 'header');
    expect(find.text('2 of 6 days'), findsOneWidget);
    expect(find.byKey(const Key('today-bar')), findsNothing);
    expect(await tester.runAsync(() => db.watchExcusedDays().first), {today});

    await tester.tap(find.text('Count today again'));
    await settle(tester);
    expect(find.text('2 of 7 days'), findsOneWidget);

    // Settings → Habits turns the numbers off.
    GoRouter.of(tester.element(find.byType(Scaffold).last))
        .go('/settings/habits');
    await settle(tester);
    await tester.tap(find.byKey(const Key('show-consistency')));
    await settle(tester);
    GoRouter.of(tester.element(find.byType(Scaffold).last)).go('/habits');
    await settle(tester);
    expect(find.text('Read Quran'), findsOneWidget);
    expect(find.text('2 of the last 7 days'), findsNothing);
    await closeApp(tester, db);
  });

  testWidgets('the consistency hadith shows once on Habits until closed', (
    tester,
  ) async {
    Future<String> assets(String path) async => path.endsWith('hadith.json')
        ? '{"hadiths":[{"id":"bukhari:6465","collection":"Sahih al-Bukhari",'
              '"book":81,"bookName":"Riqaq","number":"6465",'
              '"text":"[ fixture 6465 text ]","arabic":"[ fixture 6465 arabic ]",'
              '"translator":"Fixture Translator"}]}'
        : fixtureAssets(path);
    final db = await pumpApp(tester, assets: assets);
    await tapTab(tester, 'Habits');
    expect(find.text('[ fixture 6465 text ]'), findsOneWidget);
    expect(find.text('[ fixture 6465 arabic ]'), findsOneWidget);
    expect(
      find.text('Sahih al-Bukhari · Book 81 · No. 6465 · Fixture Translator'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('consistency-hadith-close')));
    await settle(tester);
    expect(find.byKey(const Key('consistency-hadith')), findsNothing);
    final settings = await tester.runAsync(() => db.watchSettings().first);
    expect(settings!['consistencyCard'], 'closed');
    await closeApp(tester, db);
  });

  testWidgets('a picked mood answers with a fixed line, Not now hides it', (
    tester,
  ) async {
    final db = memoryDb();
    await tester.runAsync(() => db.addHabit('Walk'));
    final today = dayKey(now);
    await pumpApp(tester, db: db);
    await scrollTo(tester, find.text('okay'));
    await tester.ensureVisible(find.text('okay'));
    await settle(tester);
    await tester.tap(find.text('okay'));
    await settle(tester);
    expect(find.text('Noted for today.'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('mood-suggestion')));
    await settle(tester);
    expect(find.text('Mark “Walk” done'), findsOneWidget);
    await tester.tap(find.byKey(const Key('mood-suggestion')));
    await settle(tester);
    final done = await tester.runAsync(() => db.watchCompletions().first);
    expect(done!.single.dayKey, today);

    await tester.ensureVisible(find.text('good'));
    await settle(tester);
    await tester.tap(find.text('good'));
    await settle(tester);
    expect(find.text('Glad to hear it.'), findsOneWidget);
    expect(find.text("Write one thing you're grateful for"), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('mood-not-now')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('mood-not-now')));
    await settle(tester);
    expect(find.byKey(const Key('mood-reply')), findsNothing);
    await closeApp(tester, db);
  });

  testWidgets('the mood week strip opens a day in Calendar', (tester) async {
    final db = memoryDb();
    final today = dayKey(now); // a Monday, so the rest of the week is ahead
    final week = weekOf(today);
    expect(week.first, today);
    await tester.runAsync(() => db.setMood(today, 3, now));
    await pumpApp(tester, db: db);
    await scrollTo(tester, find.byKey(const Key('mood-week')));
    await tester.ensureVisible(find.byKey(Key('mood-week-${week[1]}')));
    await settle(tester);
    // Days still ahead do nothing.
    await tester.tap(find.byKey(Key('mood-week-${week[1]}')));
    await settle(tester);
    expect(find.byKey(const Key('mood-week')), findsOneWidget);
    await tester.tap(find.byKey(Key('mood-week-$today')));
    await settle(tester);
    expect(find.text('Mon 5 October'), findsOneWidget);
    await closeApp(tester, db);
  });

  testWidgets('journal gratitude lines save and show on the Calendar day', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await tapTab(tester, 'Journal');
    expect(find.text(journalPromptFor('2026-10-05')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('gratitude-0')), 'Sunshine');
    await tester.enterText(find.byKey(const Key('gratitude-2')), 'Tea');
    await tester.pump(const Duration(milliseconds: 500));
    await settle(tester);
    final j = await tester.runAsync(() => db.watchJournals().first);
    expect(gratitudeLines(j!.single), ['Sunshine', '', 'Tea']);

    await tapTab(tester, 'Calendar');
    await scrollTo(tester, find.byKey(const Key('calendar-gratitude-0')));
    expect(find.text('Grateful 1. Sunshine'), findsOneWidget);
    expect(find.text('Grateful 3. Tea'), findsOneWidget);
    await closeApp(tester, db);
  });

  testWidgets('duas are added, answered, moved back and deleted', (
    tester,
  ) async {
    final db = await pumpApp(tester);
    await tapTab(tester, 'More');
    await tester.tap(find.text('Duas'));
    await settle(tester);
    expect(
      find.text('Write the duas you are making. Only you see them.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.byKey(const Key('dua-text')),
      'Ease for my family',
    );
    await tester.enterText(find.byKey(const Key('dua-note')), 'every night');
    await tester.tap(find.byKey(const Key('dua-add')));
    await settle(tester);
    expect(find.text('Asking · 1'), findsOneWidget);
    expect(find.text('every night'), findsOneWidget);
    expect(find.text('Added 5 Oct'), findsOneWidget);

    final id = (await tester.runAsync(() => db.watchDuas().first))!.single.id;
    await tester.tap(find.byKey(Key('dua-answer-$id')));
    await settle(tester);
    expect(find.text('Answered · 1'), findsOneWidget);
    expect(find.text('Answered 5 Oct'), findsOneWidget);

    await tester.tap(find.byKey(Key('dua-menu-$id')));
    await settle(tester);
    await tester.tap(find.text('Move back to Asking'));
    await settle(tester);
    expect(find.text('Asking · 1'), findsOneWidget);

    await tester.tap(find.byKey(Key('dua-menu-$id')));
    await settle(tester);
    await tester.tap(find.text('Delete'));
    await settle(tester);
    await tester.tap(find.widgetWithText(TextButton, 'Delete'));
    await settle(tester);
    expect(await tester.runAsync(() => db.watchDuas().first), isEmpty);
    await closeApp(tester, db);
  });

  testWidgets('duas are locked with the journal lock', (tester) async {
    final lock = FakeLock(accept: false);
    final db = memoryDb();
    await tester.runAsync(() async {
      await db.addDua('Private dua', null, now);
      await db.putSetting('journalLock', 'true');
    });
    await pumpApp(tester, db: db, lock: lock);
    await tapTab(tester, 'More');
    await tester.tap(find.text('Duas'));
    await settle(tester);
    expect(find.text('Your duas are locked'), findsOneWidget);
    expect(find.text('Private dua'), findsNothing);
    lock.accept = true;
    await tester.tap(find.byKey(const Key('unlock-duas')));
    await settle(tester);
    expect(find.text('Private dua'), findsOneWidget);
    expect(lock.asked, 1);
    await closeApp(tester, db);
  });

  testWidgets('a fresh install opens the first-run steps once', (tester) async {
    final db = await pumpApp(tester, firstRun: true);
    expect(find.text('Where are you?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('welcome-skip')));
    await settle(tester);
    expect(find.text('Pick a few habits'), findsOneWidget);
    await tester.tap(find.byKey(const Key('starter-Walk')));
    await tester.tap(find.byKey(const Key("starter-Read Qur'an")));
    await settle(tester);
    await tester.tap(find.byKey(const Key('welcome-next')));
    await settle(tester);
    expect(find.text('Your data stays on this phone'), findsOneWidget);
    await tester.tap(find.text('Start'));
    await settle(tester);

    final habits = await tester.runAsync(() => db.watchHabits().first);
    expect(habits!.map((h) => h.name), ["Read Qur'an", 'Walk']);
    final settings = await tester.runAsync(() => db.watchSettings().first);
    expect(settings!['onboarded'], 'true');
    expect(find.text('Where are you?'), findsNothing);
    await scrollTo(tester, find.text('Walk'));
    expect(find.text('Walk'), findsOneWidget);
    await closeApp(tester, db);
  });

  testWidgets('first run is skipped once set up, and Skip all ends it', (
    tester,
  ) async {
    final db = memoryDb();
    await tester.runAsync(() => db.putSetting('city', 'London'));
    await pumpApp(tester, db: db, firstRun: true);
    expect(find.text('Where are you?'), findsNothing);
    await closeApp(tester, db);

    final fresh = await pumpApp(tester, firstRun: true);
    await tester.tap(find.byKey(const Key('welcome-skip-all')));
    await settle(tester);
    expect(find.text('Where are you?'), findsNothing);
    expect(
      (await tester.runAsync(() => fresh.watchSettings().first))!['onboarded'],
      'true',
    );
    await closeApp(tester, fresh);
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
