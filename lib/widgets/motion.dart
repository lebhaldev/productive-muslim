import 'package:flutter/material.dart';

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
