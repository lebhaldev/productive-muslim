import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Motion tokens. Every animation goes through [motion] so the phone's
/// "Remove animations" setting turns them all off.
class Motion {
  static const quick = Duration(milliseconds: 150);
  static const medium = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
}

/// Settings → Appearance → Animations. [follow] honours the phone's
/// "Remove animations"; [always] plays them anyway; [off] stops them.
enum MotionPref {
  follow('Follow phone'),
  always('Always on'),
  off('Off');

  const MotionPref(this.label);
  final String label;

  static MotionPref parse(String? s) =>
      values.firstWhere((m) => m.name == s, orElse: () => follow);

  /// Set at the app root from settings, like AppColors.current.
  static MotionPref current = follow;
}

/// True when animations should be skipped.
bool reduceMotion(BuildContext context) => switch (MotionPref.current) {
  MotionPref.always => false,
  MotionPref.off => true,
  MotionPref.follow => MediaQuery.maybeDisableAnimationsOf(context) ?? false,
};

Duration motion(BuildContext context, Duration d) =>
    reduceMotion(context) ? Duration.zero : d;

/// Fades and slightly scales between children; for small state changes such
/// as a habit being checked or a count changing.
class PopSwitcher extends StatelessWidget {
  const PopSwitcher({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: motion(context, Motion.medium),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, a) => FadeTransition(
        opacity: a,
        child: ScaleTransition(
          scale: Tween(begin: 0.6, end: 1.0).animate(a),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Fades [child] in whenever [trigger] changes (used for tab switches, where
/// the screens are kept alive and cannot be swapped by an AnimatedSwitcher).
class FadeOnChange extends StatefulWidget {
  const FadeOnChange({super.key, required this.trigger, required this.child});
  final Object trigger;
  final Widget child;

  @override
  State<FadeOnChange> createState() => _FadeOnChangeState();
}

class _FadeOnChangeState extends State<FadeOnChange>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, value: 1);

  @override
  void didUpdateWidget(FadeOnChange old) {
    super.didUpdateWidget(old);
    if (old.trigger != widget.trigger) {
      _c.duration = motion(context, Motion.slow);
      if (_c.duration == Duration.zero) return;
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(a),
        child: ScaleTransition(
          scale: Tween(begin: 0.97, end: 1.0).animate(a),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Fades and lifts [child] in once when it first appears, after [delay].
/// With [enabled] false (or animations off) it shows at once.
class Entrance extends StatefulWidget {
  const Entrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.enabled = true,
  });
  final Widget child;
  final Duration delay;
  final bool enabled;

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this);
  late final _curve = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c.isAnimating || _c.value > 0) return;
    final d = motion(context, Motion.slow);
    if (!widget.enabled || d == Duration.zero) {
      _c.value = 1;
      return;
    }
    _c.duration = d;
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _curve,
    child: SlideTransition(
      position: Tween(
        begin: const Offset(0, 0.12),
        end: Offset.zero,
      ).animate(_curve),
      child: widget.child,
    ),
  );
}

/// A soft ring that spreads out from [child] when [on] turns true, with a
/// light haptic tick (habit and prayer check-offs).
class TickBurst extends StatefulWidget {
  const TickBurst({
    super.key,
    required this.on,
    required this.color,
    required this.child,
  });
  final bool on;
  final Color color;
  final Widget child;

  @override
  State<TickBurst> createState() => _TickBurstState();
}

class _TickBurstState extends State<TickBurst>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this);
  var _seed = 0;

  // 0.85 → 1.15 → 1: the check-off pop.
  late final _pop = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 15),
    TweenSequenceItem(
      tween: Tween(
        begin: 0.85,
        end: 1.18,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.18,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 50,
    ),
  ]).animate(_c);

  @override
  void didUpdateWidget(TickBurst old) {
    super.didUpdateWidget(old);
    if (!old.on && widget.on) {
      HapticFeedback.lightImpact();
      if (reduceMotion(context)) return;
      _seed++;
      _c.duration = const Duration(milliseconds: 650);
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _RingPainter(_c, widget.color, _seed),
    child: ScaleTransition(scale: _pop, child: widget.child),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.a, this.color, this.seed) : super(repaint: a);
  final Animation<double> a;
  final Color color;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final t = a.value;
    if (t == 0 || t == 1) return;
    final c = size.center(Offset.zero);
    final base = size.shortestSide / 2;
    final e = Curves.easeOut.transform(t);
    canvas.drawCircle(
      c,
      base * (1 + 1.3 * e),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 * (1 - t)
        ..color = color.withValues(alpha: 1 - t),
    );
    // Eight sparks flying out.
    final rnd = math.Random(seed);
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + rnd.nextDouble() * 0.4;
      final d = base * (0.9 + 1.6 * e);
      final p = c + Offset(math.cos(angle), math.sin(angle)) * d;
      canvas.drawCircle(
        p,
        2.6 * (1 - t) + 0.6,
        Paint()..color = color.withValues(alpha: (1 - t) * 0.9),
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.seed != seed;
}

/// A short, gentle burst of coloured dots when [play] turns true (all of
/// today's habits and prayers done). Draws over its child, never blocks taps.
class Celebration extends StatefulWidget {
  const Celebration({
    super.key,
    required this.play,
    required this.colors,
    required this.child,
  });
  final bool play;
  final List<Color> colors;
  final Widget child;

  @override
  State<Celebration> createState() => _CelebrationState();
}

class _CelebrationState extends State<Celebration>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this);
  var _seed = 0;

  @override
  void didUpdateWidget(Celebration old) {
    super.didUpdateWidget(old);
    if (!old.play && widget.play) {
      HapticFeedback.mediumImpact();
      if (reduceMotion(context)) return;
      _seed++;
      _c.duration = const Duration(milliseconds: 1800);
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    foregroundPainter: _BurstPainter(_c, widget.colors, _seed),
    child: widget.child,
  );
}

class _BurstPainter extends CustomPainter {
  _BurstPainter(this.a, this.colors, this.seed) : super(repaint: a);
  final Animation<double> a;
  final List<Color> colors;
  final int seed;

  @override
  void paint(Canvas canvas, Size size) {
    final t = a.value;
    if (t == 0 || t == 1) return;
    final rnd = math.Random(seed);
    final e = Curves.easeOutCubic.transform(t);
    final fade = t < 0.7 ? 1.0 : 1 - (t - 0.7) / 0.3;
    // Confetti from two points along the top, falling with a little spin.
    for (var i = 0; i < 44; i++) {
      final origin = Offset(size.width * (i.isEven ? 0.25 : 0.75), 20);
      final angle = math.pi * (1.1 + rnd.nextDouble() * 0.8);
      final speed = 80 + rnd.nextDouble() * 160;
      final p =
          origin +
          Offset(math.cos(angle), math.sin(angle)) * speed * e +
          Offset(0, 220 * t * t);
      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: fade);
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(t * 8 * (rnd.nextDouble() - 0.5));
      if (i % 3 == 0) {
        canvas.drawCircle(Offset.zero, 3.5, paint);
      } else {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: 9, height: 5),
            const Radius.circular(1.5),
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.seed != seed;
}

/// A two-colour wash whose light drifts slowly corner to corner (one sway
/// every 8 s); still when animations are off.
class DriftingWash extends StatefulWidget {
  const DriftingWash({
    super.key,
    required this.colors,
    required this.child,
    this.radius = 0,
  });
  final List<Color> colors;
  final Widget child;
  final double radius;

  @override
  State<DriftingWash> createState() => _DriftingWashState();
}

class _DriftingWashState extends State<DriftingWash>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 8),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    child: widget.child,
    builder: (context, child) {
      final t = Curves.easeInOut.transform(_c.value);
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(-1 + t * 0.8, -1),
            end: Alignment(1 - t * 0.6, 1),
            colors: widget.colors,
            stops: [0.15 + 0.2 * t, 1],
          ),
        ),
        child: child,
      );
    },
  );
}
