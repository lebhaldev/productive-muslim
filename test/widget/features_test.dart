import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:nurday/app/app.dart';
import 'package:nurday/app/providers.dart';
import 'package:nurday/data/compass.dart';
import 'package:nurday/data/db/database.dart';
import 'package:nurday/data/prayer/prayer.dart';
import 'package:nurday/features/today/share_card.dart';

import '../helpers.dart';
import 'app_flow_test.dart' show settle, scrollTo;

void main() {
  final now = DateTime(2026, 10, 5, 7, 12);

  Future<AppDatabase> pump(
    WidgetTester tester, {
    AppDatabase? db,
    DateTime? at,
    ShareImage? share,
    Compass? compass,
    FakeHomeWidget? homeWidget,
    FakePlayer? player,
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
            at ?? now,
            homeWidget: homeWidget,
            player: player,
          ),
          if (share != null) shareImageProvider.overrideWithValue(share),
          if (compass != null) compassProvider.overrideWithValue(compass),
        ],
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

  testWidgets('sharing an ayah sends an image with its reference', (
    tester,
  ) async {
    final shared = <(int, String)>[];
    final db = await pump(
      tester,
      share: (png, caption) async => shared.add((png.length, caption)),
    );
    await tester.tap(find.byKey(const Key('content-share-ayah')));
    await settle(tester);
    expect(find.byType(ShareCardView), findsOneWidget);
    await tester.tap(find.byKey(const Key('share-confirm')));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await settle(tester);
    expect(shared, hasLength(1));
    expect(shared.single.$1, greaterThan(1000), reason: 'a real PNG');
    expect(
      shared.single.$2,
      contains('Surah Ash-Sharh 94:5 · Saheeh International'),
    );
    expect(find.byType(ShareCardView), findsNothing, reason: 'dialog closed');
    await close(tester, db);
  });

  testWidgets('live Qibla says which way to turn and when you face it', (
    tester,
  ) async {
    final compass = FakeCompass();
    final db = memoryDb();
    await tester.runAsync(() => db.putSetting('city', 'London'));
    await pump(tester, db: db, compass: compass);
    await go(tester, '/more/qibla');
    final qibla = qiblaBearing(51.51, -0.13);
    compass.emit(qibla - 30);
    await settle(tester);
    expect(find.text('Turn 30° right'), findsOneWidget);
    compass.emit(qibla + 2);
    await settle(tester);
    expect(find.text('Facing the Qibla'), findsWidgets);
    await close(tester, db);
  });

  testWidgets('the home-screen widget gets today and tomorrow\'s times', (
    tester,
  ) async {
    final widget = FakeHomeWidget();
    final db = memoryDb();
    await tester.runAsync(() => db.putSetting('city', 'London'));
    await pump(tester, db: db, homeWidget: widget);
    final last = widget.writes.last;
    final times = jsonDecode(last['np_times']!) as List;
    expect(times, hasLength(10), reason: 'five prayers, two days');
    expect(times.first['n'], 'Fajr');
    expect(last['np_place'], 'London');
    expect(last['np_title'], 'Next prayer');
    await close(tester, db);
  });

  testWidgets('the ayah card plays the ayah and the bar can stop it', (
    tester,
  ) async {
    final player = FakePlayer();
    final db = await pump(tester, player: player);
    await tester.tap(find.byKey(const Key('content-play-ayah')));
    await settle(tester);
    expect(player.urls, ['https://cdn.example/fixture/6126.mp3']);
    expect(find.byKey(const Key('now-playing')), findsOneWidget);
    expect(find.text('Ayah 94:5'), findsOneWidget);
    await tester.tap(find.byKey(const Key('now-playing-stop')));
    await settle(tester);
    expect(find.byKey(const Key('now-playing')), findsNothing);
    await close(tester, db);
  });

  testWidgets('Listen plays a whole surah ayah by ayah', (tester) async {
    final player = FakePlayer();
    final db = await pump(tester, player: player);
    await go(tester, '/more/listen');
    expect(find.text('Fixture Reciter One'), findsOneWidget);
    await tester.tap(find.byKey(const Key('listen-play')));
    await settle(tester);
    expect(player.urls, hasLength(3));
    expect(find.text('Ayah 1 of 3'), findsOneWidget);
    await tester.tap(find.byTooltip('Next ayah'));
    await settle(tester);
    expect(find.text('Ayah 2 of 3'), findsOneWidget);
    expect(find.text('Surah 1 · ayah 2 of 3'), findsOneWidget);
    await close(tester, db);
  });
}

class FakeCompass implements Compass {
  final _c = StreamController<double>.broadcast();
  void emit(double h) => _c.add(h);
  @override
  Stream<double> headings() => _c.stream;
  @override
  Future<double> declination(double lat, double lon) async => 0;
}
