import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/copy.dart';
import '../../core/day_key.dart';
import '../../core/moods.dart';
import '../../widgets/common.dart';

typedef WeekCounts = ({
  int habitDays,
  int habitOf,
  int prayers,
  int? mostlyMood,
  int journalDays,
});

/// The 7 days ending [today]. Habit days have at least one habit done;
/// excused days leave the habit count (FR-18). The most frequent mood wins,
/// ties going to the later day.
WeekCounts weekCounts({
  required String today,
  required Map<int, Set<String>> completions,
  required Set<String> excused,
  required Map<String, Set<String>> prayers,
  required Map<String, int> moods,
  required Set<String> journalDays,
}) {
  final days = [for (var b = 6; b >= 0; b--) shiftDay(today, -b)];
  final doneDays = completions.values.expand((d) => d).toSet();
  final counted = days.where((d) => !excused.contains(d));
  final tally = <int, int>{};
  int? mostly;
  for (final d in days) {
    final m = moods[d];
    if (m == null) continue;
    tally[m] = (tally[m] ?? 0) + 1;
    if (mostly == null || tally[m]! >= tally[mostly]!) mostly = m;
  }
  return (
    habitDays: counted.where(doneDays.contains).length,
    habitOf: counted.length,
    prayers: days.fold(0, (n, d) => n + (prayers[d]?.length ?? 0)),
    mostlyMood: mostly,
    journalDays: days.where(journalDays.contains).length,
  );
}

/// Friday card on Reflect (fixed lines, FR-19).
class WeeklyReviewCard extends ConsumerWidget {
  const WeeklyReviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = watchToday(ref);
    final c = weekCounts(
      today: today,
      completions: ref.watch(completionsProvider).value ?? const {},
      excused: ref.watch(excusedDaysProvider).value ?? const {},
      prayers: ref.watch(prayerLogsProvider).value ?? const {},
      moods: ref.watch(moodsProvider).value ?? const {},
      journalDays: (ref.watch(journalsProvider).value ?? const {}).keys.toSet(),
    );
    return NCard(
      key: const Key('weekly-review'),
      gap: 8,
      children: [
        const Kicker(weeklyTitle),
        Text(weeklyHabits(c.habitDays, c.habitOf)),
        if (settingsOf(ref).showFaith) Text(weeklyPrayers(c.prayers)),
        Text(
          weeklyMood(c.mostlyMood == null ? null : moodLabel(c.mostlyMood!)),
        ),
        Text(weeklyJournal(c.journalDays)),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton(
            key: const Key('weekly-note'),
            onPressed: () => openJournal(context, ref, today),
            child: const Text(weeklyNoteLabel),
          ),
        ),
      ],
    );
  }
}
