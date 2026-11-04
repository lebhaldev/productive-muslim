import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/compass.dart';
import '../../data/prayer/prayer.dart';
import '../../l10n/strings.dart';
import '../../widgets/common.dart';
import '../more/more_screen.dart';

/// Within this many degrees the phone counts as facing the Qibla.
const qiblaTolerance = 4.0;

/// More → Prayer times → Live Qibla: a compass that turns with the phone.
/// Uses the phone's motion and magnetic sensors on the device only.
class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  bool _wasFacing = false;

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(prayerLocationProvider);
    if (loc == null) {
      return const ScreenBody(
        children: [
          MoreTitle('Live Qibla'),
          Note('Set your city in Settings to see the Qibla.'),
        ],
      );
    }
    final qibla = qiblaBearing(loc.lat, loc.lon);
    final live = ref.watch(headingProvider);
    final decl = ref.watch(declinationProvider).value ?? 0;
    return ScreenBody(
      children: [
        const MoreTitle('Live Qibla'),
        live.when(
          loading: () => const NCard(children: [LinearProgressIndicator()]),
          error: (_, _) => const NCard(
            children: [
              Note(
                'This phone has no compass sensor. Use the fixed bearing on the Prayer screen.',
                warn: true,
              ),
            ],
          ),
          data: (magnetic) {
            final trueHeading = (magnetic + decl + 360) % 360;
            final off = angleDiff(trueHeading, qibla);
            final facing = off.abs() <= qiblaTolerance;
            if (facing && !_wasFacing) HapticFeedback.mediumImpact();
            _wasFacing = facing;
            return NCard(
              key: const Key('qibla-live'),
              color: facing ? AppColors.sage200 : null,
              gap: 12,
              children: [
                Center(
                  child: Semantics(
                    label: facing
                        ? tr('Facing the Qibla')
                        : tr('Turn {0}° {1}', [
                            off.abs().round(),
                            off > 0 ? tr('right') : tr('left'),
                          ]),
                    child: SizedBox.square(
                      dimension: 260,
                      child: CustomPaint(
                        painter: _LiveCompassPainter(
                          heading: trueHeading,
                          qibla: qibla,
                          facing: facing,
                        ),
                      ),
                    ),
                  ),
                ),
                Text(
                  facing
                      ? tr('Facing the Qibla')
                      : tr('Turn {0}° {1}', [
                          off.abs().round(),
                          off > 0 ? tr('right') : tr('left'),
                        ]),
                  key: const Key('qibla-status'),
                  textAlign: TextAlign.center,
                  style: heading(22),
                ),
                Tr(
                  'Qibla {0}° from true North · you face {1}°',
                  args: [qibla.round(), trueHeading.round()],
                  textAlign: TextAlign.center,
                  style: meta(),
                ),
              ],
            );
          },
        ),
        const Note(
          'Hold the phone flat, away from metal and magnets. If the needle seems off, move the phone in a figure 8 to calibrate. Sensor readings stay on this phone.',
        ),
      ],
    );
  }
}

class _LiveCompassPainter extends CustomPainter {
  _LiveCompassPainter({
    required this.heading,
    required this.qibla,
    required this.facing,
  });
  final double heading;
  final double qibla;
  final bool facing;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 6;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = AppColors.neutral400;
    canvas.drawCircle(c, r, ring);
    // The dial turns against the phone so North stays North.
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-heading * math.pi / 180);
    final tick = Paint()
      ..color = AppColors.neutral600
      ..strokeWidth = 2;
    for (var d = 0; d < 360; d += 30) {
      final a = d * math.pi / 180;
      final len = d % 90 == 0 ? 14.0 : 7.0;
      canvas.drawLine(
        Offset(math.sin(a) * (r - len), -math.cos(a) * (r - len)),
        Offset(math.sin(a) * r, -math.cos(a) * r),
        tick,
      );
    }
    final n = TextPainter(
      text: TextSpan(
        text: 'N',
        style: TextStyle(
          color: AppColors.accent700,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    n.paint(canvas, Offset(-n.width / 2, -r + 16));
    // Qibla needle, fixed to the dial at its bearing.
    final q = qibla * math.pi / 180;
    final needle = Paint()
      ..color = facing ? AppColors.sage600 : AppColors.accent700
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final tip = Offset(math.sin(q) * (r - 24), -math.cos(q) * (r - 24));
    canvas.drawLine(Offset.zero, tip, needle);
    canvas.drawCircle(tip, 10, Paint()..color = needle.color);
    canvas.restore();
    // The phone's own direction: a fixed mark at the top.
    final top = Paint()..color = AppColors.text;
    final path = Path()
      ..moveTo(c.dx, c.dy - r - 4)
      ..lineTo(c.dx - 9, c.dy - r + 12)
      ..lineTo(c.dx + 9, c.dy - r + 12)
      ..close();
    canvas.drawPath(path, top);
    canvas.drawCircle(c, 6, top);
  }

  @override
  bool shouldRepaint(_LiveCompassPainter old) =>
      old.heading != heading || old.qibla != qibla || old.facing != facing;
}
