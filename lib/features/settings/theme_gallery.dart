import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../l10n/strings.dart';
import '../../widgets/motion.dart';

/// A small phone drawn in [theme]'s own colours: header wash, three habits,
/// mood dots and the main button. Used for the featured themes.
class ThemeCard extends StatelessWidget {
  const ThemeCard({
    super.key,
    required this.theme,
    required this.selected,
    required this.onTap,
  });
  final ColorTheme theme;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = theme.paletteFor(Theme.of(context).brightness);
    final d = motion(context, Motion.medium);
    Widget habit(bool done) => Container(
      height: 15,
      margin: const EdgeInsets.only(top: 5),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? p.sage600 : null,
              border: Border.all(color: p.sage600, width: 1.4),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: p.neutral400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: tr('{0} colours', [tr(theme.label)]),
      excludeSemantics: true,
      child: GestureDetector(
        key: Key('color-theme-${theme.name}'),
        onTap: onTap,
        child: AnimatedScale(
          duration: d,
          curve: Curves.easeOutBack,
          scale: selected ? 1.0 : 0.93,
          child: SizedBox(
            width: 104,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: d,
                  height: 150,
                  decoration: BoxDecoration(
                    color: p.bg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: selected ? p.accent700 : p.divider,
                      width: selected ? 3 : 1,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: p.accent700.withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 40,
                            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [p.sage200, p.accent200],
                              ),
                            ),
                            child: Container(
                              alignment: AlignmentDirectional.topStart,
                              child: Container(
                                width: 46,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: p.text,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(7, 2, 7, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                habit(true),
                                habit(true),
                                habit(false),
                                const SizedBox(height: 7),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    for (final c in p.moods)
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: c,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Align(
                                  alignment: AlignmentDirectional.centerStart,
                                  child: Container(
                                    width: 52,
                                    height: 13,
                                    decoration: BoxDecoration(
                                      color: p.accent700,
                                      borderRadius: BorderRadius.circular(
                                        AppRadii.pill,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      PositionedDirectional(
                        top: 6,
                        end: 6,
                        child: AnimatedScale(
                          duration: d,
                          curve: Curves.elasticOut,
                          scale: selected ? 1 : 0,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: p.accent700,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              size: 14,
                              color: p.onAccent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // The list has a fixed height, so the name grows only a
                // little with large text.
                MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.3,
                  child: Text(
                    tr(theme.label),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The featured themes side by side, scrolled so the picked one shows.
class FeaturedThemes extends StatefulWidget {
  const FeaturedThemes({
    super.key,
    required this.selected,
    required this.onPick,
  });
  final ColorTheme selected;
  final ValueChanged<ColorTheme> onPick;

  @override
  State<FeaturedThemes> createState() => _FeaturedThemesState();
}

class _FeaturedThemesState extends State<FeaturedThemes> {
  static const _item = 116.0;
  late final _scroll = ScrollController(
    initialScrollOffset: () {
      final i = ColorTheme.featured.indexOf(widget.selected);
      return i <= 0 ? 0.0 : (i - 1) * _item;
    }(),
  );

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 190,
    child: ListView.separated(
      key: const Key('featured-themes'),
      controller: _scroll,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: ColorTheme.featured.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (_, i) {
        final t = ColorTheme.featured[i];
        return ThemeCard(
          theme: t,
          selected: t == widget.selected,
          onTap: () => widget.onPick(t),
        );
      },
    ),
  );
}

/// A live sample of Today in the current colours for the first-run colour
/// step: the header wash drifts and the habits tick themselves off in turn,
/// so the picked theme shows its motion as well as its colours.
class LiveThemePreview extends StatefulWidget {
  const LiveThemePreview({super.key});

  @override
  State<LiveThemePreview> createState() => _LiveThemePreviewState();
}

class _LiveThemePreviewState extends State<LiveThemePreview> {
  static const _habits = ["Read Qur'an", 'Morning adhkar', 'Walk'];
  var _done = 1;
  Timer? _timer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _timer?.cancel();
    if (reduceMotion(context)) {
      _done = 2;
    } else {
      _timer = Timer.periodic(const Duration(milliseconds: 1300), (_) {
        if (mounted) setState(() => _done = (_done + 1) % 4);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('theme-preview'),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Celebration(
        play: _done == 3,
        colors: [
          AppColors.sage600,
          AppColors.accent400,
          AppColors.sage400,
          AppColors.accent700,
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DriftingWash(
              colors: [AppColors.sage200, AppColors.accent200],
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    Expanded(child: Tr('Good morning', style: heading(22))),
                    PopSwitcher(
                      child: Text(
                        '$_done/3',
                        key: ValueKey(_done),
                        style: heading(18, color: AppColors.sage900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < _habits.length; i++)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                      child: Row(
                        children: [
                          TickBurst(
                            on: i < _done,
                            color: AppColors.sage600,
                            child: AnimatedContainer(
                              duration: motion(context, Motion.medium),
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i < _done ? AppColors.sage600 : null,
                                border: Border.all(
                                  color: AppColors.sage600,
                                  width: 2,
                                ),
                              ),
                              child: i < _done
                                  ? Icon(
                                      Icons.check,
                                      size: 14,
                                      color: AppColors.bg,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Tr(_habits[i])),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      for (final c in AppColors.current.moods)
                        Expanded(
                          child: Container(
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: c,
                              borderRadius: BorderRadius.circular(
                                AppRadii.pill,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FilledButton(
                      onPressed: () {},
                      child: const Tr("Write today's journal"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
