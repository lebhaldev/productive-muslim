import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/widgets/motion.dart';

void main() {
  double opacity(WidgetTester t) => t
      .widget<FadeTransition>(
        find.descendant(
          of: find.byType(Entrance),
          matching: find.byType(FadeTransition),
        ),
      )
      .opacity
      .value;

  Widget app(bool reduce, Widget child) => MaterialApp(
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
        child: child,
      ),
    ),
  );

  testWidgets('entrances fade in, or show at once with animations off', (
    tester,
  ) async {
    await tester.pumpWidget(app(false, const Entrance(child: Text('Hi'))));
    expect(opacity(tester), 0);
    // Frame 1 fires the delay timer, frame 2 starts the fade.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(opacity(tester), inExclusiveRange(0, 1));
    await tester.pump(const Duration(milliseconds: 500));
    expect(opacity(tester), 1);

    await tester.pumpWidget(
      app(true, const Entrance(key: Key('b'), child: Text('Hi'))),
    );
    expect(opacity(tester), 1);
  });

  testWidgets('tick and celebration only play when turning on', (tester) async {
    Widget build(bool on) => app(
      false,
      Celebration(
        play: on,
        colors: const [Colors.green],
        child: TickBurst(
          on: on,
          color: Colors.green,
          child: const SizedBox(width: 20, height: 20),
        ),
      ),
    );
    await tester.pumpWidget(build(false));
    await tester.pumpWidget(build(true));
    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.hasRunningAnimations, isFalse);
    await tester.pumpWidget(build(true));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse, reason: 'stays on: no replay');
  });
}
