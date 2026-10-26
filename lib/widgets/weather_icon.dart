import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/weather/weather.dart';
import 'motion.dart';

/// Line weather icons drawn in code (design section 12): the sun's rays turn
/// once every 24 s, clouds drift, rain and snow fall, lightning flickers
/// every 3 s. Still when the phone asks for reduced motion.
class WeatherIcon extends StatefulWidget {
  const WeatherIcon({super.key, required this.kind, this.size = 40});
  final WeatherKind kind;
  final double size;

  @override
  State<WeatherIcon> createState() => _WeatherIconState();
}

class _WeatherIconState extends State<WeatherIcon>
    with SingleTickerProviderStateMixin {
  // One 24 s loop; faster motions repeat inside it.
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final still = motion(context, Motion.slow) == Duration.zero;
    if (still) {
      _c.stop();
      _c.value = 0.1;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Decorative: the weather chip around it says the condition in words.
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _WeatherPainter(
            widget.kind,
            _c,
            line: AppColors.text,
            sun: AppColors.accent700,
            water: AppColors.sage600,
          ),
        ),
      ),
    );
  }
}

class _WeatherPainter extends CustomPainter {
  _WeatherPainter(
    this.kind,
    this.t, {
    required this.line,
    required this.sun,
    required this.water,
  }) : super(repaint: t);
  final WeatherKind kind;
  final Animation<double> t;
  final Color line, sun, water;

  @override
  void paint(Canvas canvas, Size size) {
    // Drawn on a 24-unit grid like Lucide, stroke 2.75.
    final k = size.width / 24;
    canvas.scale(k);
    final v = t.value;
    Paint stroke(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.75 * (24 / size.width).clamp(0.5, 1.0)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    // Cloud drift: ±1.5 units, one sway every 6 s.
    final drift = math.sin(v * 4 * 2 * math.pi) * 1.5;

    void sunAt(Offset c, double r, double ray) {
      canvas.drawCircle(c, r, stroke(sun));
      for (var i = 0; i < 8; i++) {
        final a = v * 2 * math.pi + i * math.pi / 4;
        final d = Offset(math.cos(a), math.sin(a));
        canvas.drawLine(c + d * (r + 2), c + d * (r + 2 + ray), stroke(sun));
      }
    }

    void cloud(Offset o, {double scale = 1}) {
      canvas.save();
      canvas.translate(o.dx, o.dy);
      canvas.scale(scale);
      final p = Path()
        ..moveTo(6.5, 19)
        ..arcToPoint(const Offset(6.5, 10), radius: const Radius.circular(4.5))
        ..arcToPoint(const Offset(17.5, 10.5), radius: const Radius.circular(6))
        ..arcToPoint(
          const Offset(17.5, 19),
          radius: const Radius.circular(4.25),
        )
        ..close();
      canvas.drawPath(p, Paint()..color = AppColors.surface);
      canvas.drawPath(p, stroke(line));
      canvas.restore();
    }

    switch (kind) {
      case WeatherKind.clear:
        sunAt(const Offset(12, 12), 4.5, 2.5);
      case WeatherKind.partlyCloudy:
        sunAt(const Offset(9, 8), 3, 1.8);
        cloud(Offset(3 + drift, 3), scale: 0.85);
      case WeatherKind.cloudy:
        cloud(Offset(drift, 0));
      case WeatherKind.fog:
        cloud(Offset(drift, -3));
        for (final (y, x) in [(19.5, 4.0), (22.5, 7.0)]) {
          final shift = math.sin(v * 3 * 2 * math.pi + y) * 1.5;
          canvas.drawLine(
            Offset(x + shift, y),
            Offset(x + 12 + shift, y),
            stroke(line),
          );
        }
      case WeatherKind.rain || WeatherKind.snow:
        cloud(Offset(drift, -4));
        final snow = kind == WeatherKind.snow;
        // Drops fall 4 units and fade, each lane offset in time.
        for (final (i, x) in [8.0, 12.0, 16.0].indexed) {
          final f = (v * (snow ? 8 : 16) + i / 3) % 1;
          final y = 16.5 + f * 5;
          final paint = stroke(water)
            ..color = water.withValues(alpha: 1 - f * 0.8);
          if (snow) {
            canvas.drawCircle(
              Offset(x + math.sin(f * math.pi * 2) * 0.8, y),
              0.9,
              paint..style = PaintingStyle.fill,
            );
          } else {
            canvas.drawLine(Offset(x, y), Offset(x - 0.6, y + 2), paint);
          }
        }
      case WeatherKind.thunder:
        cloud(Offset(drift, -4));
        // A flicker for the first tenth of every 3 s.
        final phase = (v * 8) % 1;
        final lit = phase < 0.06 || (phase > 0.09 && phase < 0.12);
        final bolt = Path()
          ..moveTo(13, 14)
          ..lineTo(10, 18.5)
          ..lineTo(13.5, 18.5)
          ..lineTo(11, 23);
        canvas.drawPath(
          bolt,
          stroke(sun)..color = sun.withValues(alpha: lit ? 1 : 0.45),
        );
      case WeatherKind.windy:
        final shift = math.sin(v * 4 * 2 * math.pi) * 1.5;
        for (final (y, len) in [(8.0, 13.0), (12.5, 17.0), (17.0, 11.0)]) {
          final p = Path()
            ..moveTo(3 + shift, y)
            ..lineTo(3 + len + shift, y)
            ..arcToPoint(
              Offset(3 + len + shift, y - 3.5),
              radius: const Radius.circular(1.75),
              clockwise: false,
            );
          canvas.drawPath(p, stroke(line));
        }
    }
  }

  @override
  bool shouldRepaint(_WeatherPainter old) =>
      old.kind != kind || old.line != line || old.sun != sun;
}
