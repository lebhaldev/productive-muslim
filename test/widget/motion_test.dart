import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/widgets/motion.dart';

void main() {
  Future<Duration> durationWith(WidgetTester tester, bool disable) async {
    late Duration d;
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: disable),
        child: Builder(
          builder: (context) {
            d = motion(context, Motion.medium);
            return const SizedBox();
          },
        ),
      ),
    );
    return d;
  }

  testWidgets('animations follow the phone setting', (tester) async {
    expect(await durationWith(tester, false), Motion.medium);
    expect(await durationWith(tester, true), Duration.zero);
  });
}
