import 'package:flutter/material.dart';

import '../app/theme.dart';
import 'motion.dart';

/// Scrollable screen body with the design's 20px side padding.
class ScreenBody extends StatelessWidget {
  const ScreenBody({super.key, required this.children, this.gap = 14});
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          children[i],
        ],
      ],
    );
  }
}

class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            container: true,
            header: true,
            child: Text(text, style: heading(28)),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class NCard extends StatelessWidget {
  const NCard({
    super.key,
    required this.children,
    this.color,
    this.gap = 8,
    this.onTap,
    this.animateSize = false,
  });
  final List<Widget> children;
  final Color? color;
  final double gap;
  final VoidCallback? onTap;

  /// Animates height changes, e.g. when an expandable card opens.
  final bool animateSize;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            children[i],
          ],
        ],
      ),
    );
    if (animateSize) {
      content = AnimatedSize(
        duration: motion(context, Motion.medium),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: content,
      );
    }
    return Material(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}

class Kicker extends StatelessWidget {
  const Kicker(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(
      fontSize: 11,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w600,
      color: AppColors.accent700,
    ),
  );
}

class Tag extends StatelessWidget {
  const Tag(this.text, {super.key, this.sage = false});
  final String text;
  final bool sage;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: sage ? AppColors.sage200 : AppColors.accent200,
      borderRadius: BorderRadius.circular(AppRadii.pill),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: sage ? AppColors.sage900 : AppColors.accent900,
      ),
    ),
  );
}

class CardTitle extends StatelessWidget {
  const CardTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: heading(17));
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton.outlined(
    tooltip: label,
    onPressed: onPressed,
    icon: Icon(icon),
    style: IconButton.styleFrom(side: BorderSide(color: AppColors.divider)),
  );
}

/// `HH:mm` for a TimeOfDay.
String hhmm(TimeOfDay t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

TimeOfDay parseHhmm(String s) {
  final p = s.split(':');
  return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
}
