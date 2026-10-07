import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/day_key.dart';
import '../../core/moods.dart';
import '../../core/streak.dart';
import '../../widgets/common.dart';
import 'more_screen.dart';

/// Last-30-days summary, computed on device (no network).
class ReflectScreen extends ConsumerWidget {
  const ReflectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = watchToday(ref);
    final moods = ref.watch(moodsProvider).value ?? const {};
    final journals = ref.watch(journalsProvider).value ?? const {};
    final habits = (ref.watch(habitsProvider).value ?? const []).where(
      (h) => !h.archived,
    );
    final done = ref.watch(completionsProvider).value ?? const {};
    final last30 = [for (var n = 29; n >= 0; n--) shiftDay(today, -n)];
    final month = today.substring(0, 7);

    return ScreenBody(
      gap: 16,
      children: [
        const MoreTitle('Reflect'),
        NCard(
          gap: 10,
          children: [
            const Kicker('Mood · last 30 days'),
            Semantics(
              container: true,
              label:
                  'Mood logged on ${last30.where(moods.containsKey).length} of the last 30 days',
              excludeSemantics: true,
              child: SizedBox(
                height: 90,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final d in last30)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 1.5),
                          child: FractionallySizedBox(
                            heightFactor: moods[d] == null
                                ? 0.06
                                : (moods[d]! + 1) * 0.2,
                            alignment: Alignment.bottomCenter,
                            child: Tooltip(
                              message: moods[d] == null
                                  ? d
                                  : '$d ${moodLabel(moods[d]!)}',
                              child: Container(
                                decoration: BoxDecoration(
                                  color: moods[d] == null
                                      ? AppColors.neutral300
                                      : AppColors.moods[moods[d]!],
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.pill,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(child: Text('30 days ago', style: meta(size: 11))),
                Text('Today', style: meta(size: 11)),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: _Stat(
                value: streak(journals.keys.toSet(), today),
                label: 'day journal streak',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Stat(
                value: journals.keys.where((k) => k.startsWith(month)).length,
                label: 'entries this month',
              ),
            ),
          ],
        ),
        NCard(
          children: [
            const Kicker('Habit check-offs · 30 days'),
            if (habits.isEmpty)
              Text('No active habits.', style: meta(size: 13)),
            for (final h in habits)
              Builder(
                builder: (context) {
                  final n = last30
                      .where((d) => done[h.id]?.contains(d) ?? false)
                      .length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              h.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text('$n', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                        child: LinearProgressIndicator(
                          value: n / 30,
                          minHeight: 8,
                          backgroundColor: AppColors.neutral200,
                          color: AppColors.sage600,
                          semanticsLabel: '${h.name}: $n of 30 days',
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});
  final int value;
  final String label;

  @override
  Widget build(BuildContext context) => NCard(
    gap: 2,
    children: [
      Text('$value', style: heading(32)),
      Text(label, style: const TextStyle(fontSize: 13)),
    ],
  );
}
