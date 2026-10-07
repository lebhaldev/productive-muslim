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

/// Header with a back arrow, for screens opened from a menu.
class SubScreenTitle extends StatelessWidget {
  const SubScreenTitle(
    this.text, {
    super.key,
    required this.onBack,
    required this.backTooltip,
  });
  final String text;
  final VoidCallback onBack;
  final String backTooltip;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        tooltip: backTooltip,
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back),
      ),
      const SizedBox(width: 4),
      Expanded(child: ScreenTitle(text)),
    ],
  );
}

/// A tappable row in a menu (More, Settings).
class NavRow extends StatelessWidget {
  const NavRow({
    super.key,
    required this.title,
    required this.sub,
    required this.onTap,
    this.icon,
  });
  final String title;
  final String sub;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.sage600),
                const SizedBox(width: 14),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: heading(17)),
                    const SizedBox(height: 2),
                    Text(sub, style: meta(size: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.neutral600),
            ],
          ),
        ),
      ),
    );
  }
}

/// A small coloured shortcut tile (Today's Journal and Activity).
class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.color,
    required this.ink,
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
  });
  final Color color;
  final Color ink;
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 96),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: ink),
                const SizedBox(height: 6),
                Text(title, style: heading(17, color: ink)),
                const SizedBox(height: 2),
                Text(
                  sub,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: ink),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Arabic scripture or poetry on its own tinted block, right to left.
class ArabicBlock extends StatelessWidget {
  const ArabicBlock(this.text, {super.key, this.size = 22, this.maxLines});
  final String text;
  final double size;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Text(
        text,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
        style: arabicStyle.copyWith(fontSize: size),
      ),
    );
  }
}

/// A short status line under a control; [warn] for problems.
class Note extends StatelessWidget {
  const Note(this.text, {super.key, this.warn = false});
  final String text;
  final bool warn;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: meta(color: warn ? AppColors.accent700 : null));
}
