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

Duration motion(BuildContext context, Duration d) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false ? Duration.zero : d;

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
      _c.duration = motion(context, Motion.medium);
      if (_c.duration == Duration.zero) return;
      _c.forward(from: 0.3);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: CurvedAnimation(parent: _c, curve: Curves.easeOut),
    child: widget.child,
  );
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
        begin: const Offset(0, 0.06),
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

  @override
  void didUpdateWidget(TickBurst old) {
    super.didUpdateWidget(old);
    if (!old.on && widget.on) {
      HapticFeedback.lightImpact();
      final d = motion(context, Motion.slow);
      if (d == Duration.zero) return;
      _c.duration = d;
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _RingPainter(_c, widget.color), child: widget.child);
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.a, this.color) : super(repaint: a);
  final Animation<double> a;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final t = a.value;
    if (t == 0 || t == 1) return;
    final r = size.shortestSide / 2 * (1 + 0.9 * Curves.easeOut.transform(t));
    canvas.drawCircle(
      size.center(Offset.zero),
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 * (1 - t)
        ..color = color.withValues(alpha: 1 - t),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) => false;
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
      if (motion(context, Motion.slow) == Duration.zero) return;
      _seed++;
      _c.duration = const Duration(milliseconds: 1400);
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
    final origin = Offset(size.width - 48, 12);
    for (var i = 0; i < 22; i++) {
      final angle = math.pi + rnd.nextDouble() * math.pi; // upwards fan
      final speed = 60 + rnd.nextDouble() * 90;
      final e = Curves.easeOutCubic.transform(t);
      final p =
          origin +
          Offset(math.cos(angle), math.sin(angle)) * speed * e +
          Offset(0, 70 * t * t); // a little gravity
      canvas.drawCircle(
        p,
        2.5 + rnd.nextDouble() * 2.5,
        Paint()..color = colors[i % colors.length].withValues(alpha: 1 - t),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.seed != seed;
}
