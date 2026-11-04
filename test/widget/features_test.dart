import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nurday/app/app.dart';
import 'package:nurday/data/db/database.dart';
import 'package:nurday/data/prayer/prayer.dart';

import '../helpers.dart';
import 'app_flow_test.dart' show settle, scrollTo;

void main() {
  final now = DateTime(2026, 10, 5, 7, 12);

  Future<AppDatabase> pump(
    WidgetTester tester, {
    AppDatabase? db,
    DateTime? at,
  }) async {
    final database = db ?? memoryDb();
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(database, at ?? now),
        child: const NurdayApp(),
      ),
    );
    await settle(tester);
    return database;
  }

  Future<void> go(WidgetTester tester, String path) async {
    GoRouter.of(tester.element(find.byType(Scaffold).last)).go(path);
    await settle(tester);
  }

  Future<void> close(WidgetTester tester, AppDatabase db) async {
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await tester.runAsync(db.close);
  }

  testWidgets('tasbih counts taps per phrase and resets', (tester) async {
    final db = await pump(tester);
    await go(tester, '/more/tasbih');
    expect(find.text('[ fixture dhikr one ]'), findsOneWidget);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.byKey(const Key('tasbih-tap')));
      await settle(tester);
    }
    expect(find.text('Today: 3'), findsOneWidget);
    expect(await tester.runAsync(() => db.watchDhikr('2026-10-05').first), {
      'subhanallah': 3,
    });
    await tester.tap(find.byKey(const Key('tasbih-undo')));
    await settle(tester);
    expect(find.text('Today: 2'), findsOneWidget);
    // The second phrase links to a bundled hadith, shown verbatim.
    await tester.tap(find.byKey(const Key('dhikr-istighfar')));
    await settle(tester);
    expect(find.text('Today: 0'), findsOneWidget);
    await scrollTo(tester, find.text('RELATED HADITH'));
    expect(find.text('[ fixture hadith arabic ]'), findsOneWidget);
    await close(tester, db);
  });

  testWidgets('Quran reading logs pages and shows khatm progress', (
    tester,
  ) async {
    final db = await pump(tester);
    await go(tester, '/more/quran');
    await tester.tap(find.byKey(const Key('quran-add-20')));
    await settle(tester);
    await tester.tap(find.byKey(const Key('quran-add-5')));
    await settle(tester);
    expect(
      tester.widget<Text>(find.byKey(const Key('quran-today'))).data,
      '25',
    );
    expect(find.text('25 of 604 pages · about juz 1'), findsOneWidget);
    expect(await tester.runAsync(() => db.watchQuranReads().first), {
      '2026-10-05': 25,
    });
    await close(tester, db);
  });

  testWidgets('a make-up fast takes one off the count you keep', (
    tester,
  ) async {
    final db = memoryDb();
    await tester.runAsync(() => db.putSetting('qadaFasts', '3'));
    await pump(tester, db: db);
    await go(tester, '/more/fasting');
    expect(
      tester.widget<Text>(find.byKey(const Key('qada-fasts-value'))).data,
      '3',
    );
    await tester.tap(find.text('Make-up fast'));
    await settle(tester);
    expect(
      tester.widget<Text>(find.byKey(const Key('qada-fasts-value'))).data,
      '2',
    );
    await tester.tap(find.text('Not fasting'));
    await settle(tester);
    expect(
      tester.widget<Text>(find.byKey(const Key('qada-fasts-value'))).data,
      '3',
      reason: 'un-logging puts it back',
    );
    await close(tester, db);
  });

  testWidgets('Ramadan shows suhoor and iftar and logs the fast', (
    tester,
  ) async {
    // The 10th of Ramadan 1448 by Umm al-Qura.
    var day = DateTime(2027, 1, 1);
    while (hijriDate(day).month != 9 || hijriDate(day).day != 10) {
      day = day.add(const Duration(days: 1));
    }
    final db = memoryDb();
    await tester.runAsync(() => db.putSetting('city', 'London'));
    final at = DateTime(day.year, day.month, day.day, 12);
    await pump(tester, db: db, at: at);
    expect(find.byKey(const Key('ramadan-card')), findsOneWidget);
    expect(find.text('Ramadan · day 10'), findsOneWidget);
    expect(find.textContaining('Iftar in'), findsOneWidget);
    await tester.tap(find.byKey(const Key('ramadan-fasting')));
    await settle(tester);
    final key =
        '${at.year}-${at.month.toString().padLeft(2, '0')}-${at.day.toString().padLeft(2, '0')}';
    expect(await tester.runAsync(() => db.watchFasts().first), {key: 'fast'});
    await close(tester, db);
  });

  testWidgets('outside Ramadan there is no Ramadan card', (tester) async {
    final db = await pump(tester);
    expect(find.byKey(const Key('ramadan-card')), findsNothing);
    await close(tester, db);
  });
}
