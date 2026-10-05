import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/app/app.dart';
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
  }) async {
    final database = db ?? memoryDb();
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(database, now, online: online),
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
      expect(find.text('Sahih al-Bukhari · Book 2 · No. 13'), findsOneWidget);
      expect(find.text('Fixture Author'), findsOneWidget);
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
      expect(find.text('1 of 1'), findsOneWidget);
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
}
