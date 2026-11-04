import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../l10n/strings.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import '../more/more_screen.dart';
import '../settings/settings_widgets.dart';

/// More → Tasbih: a counter for common dhikr phrases, counted per day on
/// this phone. The phrases come from `assets/content/dhikr.json`; the app
/// adds no meaning or reward text, only a bundled hadith where one names
/// the phrase.
class TasbihScreen extends ConsumerStatefulWidget {
  const TasbihScreen({super.key});

  @override
  ConsumerState<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends ConsumerState<TasbihScreen> {
  String? _phrase;

  int get _target =>
      int.tryParse(settingsOf(ref).raw['tasbihTarget'] ?? '') ?? 33;

  Future<void> _count(String id, int delta) async {
    final db = ref.read(databaseProvider);
    final day = watchToday(ref);
    final n = await db.addDhikr(day, id, delta);
    if (delta > 0) {
      final t = _target;
      if (t > 0 && n % t == 0) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.selectionClick();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final phrases = ref.watch(dhikrPhrasesProvider).value ?? const [];
    final counts = ref.watch(dhikrTodayProvider).value ?? const <String, int>{};
    if (phrases.isEmpty) {
      return const ScreenBody(children: [MoreTitle('Tasbih')]);
    }
    final p = phrases.firstWhere(
      (x) => x.id == _phrase,
      orElse: () => phrases.first,
    );
    final today = counts[p.id] ?? 0;
    final target = _target;
    final inRound = target == 0 ? today : today % target;
    final rounds = target == 0 ? 0 : today ~/ target;
    return ScreenBody(
      children: [
        const MoreTitle('Tasbih'),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final x in phrases)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 6),
                  child: ChoiceChip(
                    key: Key('dhikr-${x.id}'),
                    label: Text(x.translit),
                    selected: x.id == p.id,
                    showCheckmark: false,
                    selectedColor: AppColors.sage300,
                    onSelected: (_) => setState(() => _phrase = x.id),
                  ),
                ),
            ],
          ),
        ),
        ArabicBlock(p.arabic, size: 30),
        Text(p.translit, textAlign: TextAlign.center, style: meta(size: 14)),
        Center(
          child: Semantics(
            button: true,
            label: tr('Count {0}, {1} today', [p.translit, today]),
            excludeSemantics: true,
            child: GestureDetector(
              key: const Key('tasbih-tap'),
              onTap: () => _count(p.id, 1),
              child: SizedBox(
                width: 230,
                height: 230,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: target == 0 ? 0 : inRound / target),
                        duration: motion(context, Motion.quick),
                        builder: (_, v, _) => CircularProgressIndicator(
                          value: target == 0 ? null : v,
                          strokeWidth: 10,
                          color: AppColors.sage600,
                          backgroundColor: AppColors.neutral200,
                        ),
                      ),
                    ),
                    Container(
                      width: 196,
                      height: 196,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PopSwitcher(
                            child: Text(
                              '$inRound',
                              key: ValueKey(today),
                              style: heading(56),
                            ),
                          ),
                          if (target > 0)
                            Text('/ $target', style: meta(size: 14)),
                          if (rounds > 0)
                            Tr(
                              '{0} rounds',
                              args: [rounds],
                              style: meta(color: AppColors.accent700),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Tr(
          'Today: {0}',
          args: [today],
          textAlign: TextAlign.center,
          style: meta(size: 13),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              key: const Key('tasbih-undo'),
              onPressed: today == 0 ? null : () => _count(p.id, -1),
              icon: const Icon(Icons.remove, size: 18),
              label: const Tr('Undo one'),
            ),
            const SizedBox(width: 10),
            TextButton(
              key: const Key('tasbih-reset'),
              onPressed: today == 0
                  ? null
                  : () => ref
                        .read(databaseProvider)
                        .resetDhikr(watchToday(ref), p.id),
              child: const Tr('Reset today'),
            ),
          ],
        ),
        SettingChoice<int>(
          key: const Key('tasbih-target'),
          value: target,
          options: const {33: '33', 99: '99', 100: '100', 0: '∞'},
          onChanged: (v) => ref.putSetting('tasbihTarget', '$v'),
        ),
        if (p.hadith != null) _RelatedHadith(id: p.hadith!),
        const Note('Counts stay on this phone, one total per phrase per day.'),
      ],
    );
  }
}

/// A bundled hadith that names the phrase, shown verbatim with its reference.
class _RelatedHadith extends ConsumerWidget {
  const _RelatedHadith({required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = ref.watch(hadithByIdProvider).value?[id];
    if (h == null) return const SizedBox.shrink();
    final arabicOnly = settingsOf(ref).arabicOnly;
    return NCard(
      gap: 8,
      children: [
        const Kicker('Related hadith'),
        if (h.arabic != null) ArabicBlock(h.arabic!, size: 18),
        if (!arabicOnly || h.arabic == null)
          Text(h.text, style: const TextStyle(fontSize: 14, height: 1.5)),
        Text(h.source, style: meta()),
      ],
    );
  }
}
