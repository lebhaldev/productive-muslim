import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/app/app.dart';

import '../helpers.dart';
import 'app_flow_test.dart' show settle;

void main() {
  final now = DateTime(2026, 10, 5, 7, 12);

  testWidgets('every tab renders at 200% text size without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final db = memoryDb();
    await tester.runAsync(() async {
      final id = await db.addHabit('No phone after 10pm');
      await db.toggleCompletion(id, '2026-10-05');
      await db.setMood('2026-10-05', 2, now);
      await db.saveJournal(
        '2026-10-05',
        'A slow day',
        'Spent the afternoon outside.',
        now,
      );
      await db.putSetting('city', 'London');
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(db, now),
        child: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: const NurdayApp(),
        ),
      ),
    );
    await settle(tester);
    expect(tester.takeException(), isNull);

    for (final tab in ['Habits', 'Calendar', 'Journal', 'More']) {
      await tester.tap(find.byKey(Key('tab-$tab')));
      await settle(tester);
      expect(tester.takeException(), isNull, reason: tab);
    }
    for (final sub in ['Activities', 'Reflect', 'Settings']) {
      await tester.tap(find.byKey(const Key('tab-More')));
      await settle(tester);
      await tester.tap(find.text(sub));
      await settle(tester);
      expect(tester.takeException(), isNull, reason: sub);
    }

    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await tester.runAsync(db.close);
  });

  testWidgets('icon-only and colour-only controls have spoken labels', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final db = memoryDb();
    await tester.runAsync(() => db.addHabit('Morning walk'));
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(db, now),
        child: const NurdayApp(),
      ),
    );
    await settle(tester);

    for (final label in ['Today', 'Habits', 'Calendar', 'Journal', 'More']) {
      expect(find.bySemanticsLabel(label), findsWidgets, reason: label);
    }
    await tester.scrollUntilVisible(
      find.text('Morning walk'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await settle(tester);
    expect(find.bySemanticsLabel('Mark done Morning walk'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('bright'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await settle(tester);
    for (final mood in ['rough', 'low', 'okay', 'good', 'bright']) {
      expect(find.bySemanticsLabel('Mood $mood'), findsOneWidget, reason: mood);
    }

    handle.dispose();
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await tester.runAsync(db.close);
  });
}
