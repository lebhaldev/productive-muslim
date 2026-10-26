import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
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

/// The most recent Friday on or before [today]: the weekly card covers the
/// Saturday to Friday week ending then.
String lastFriday(String today) =>
    shiftDay(today, -((parseDayKey(today).weekday - DateTime.friday) % 7));

/// `3–9 Oct`, or `26 Sep – 2 Oct` across a month end.
String weekRangeLabel(String friday) {
  final end = parseDayKey(friday), start = parseDayKey(shiftDay(friday, -6));
  return start.month == end.month
      ? '${start.day}–${DateFormat('d MMM').format(end)}'
      : '${DateFormat('d MMM').format(start)} – ${DateFormat('d MMM').format(end)}';
}

/// Weekly card on Reflect, from Friday until Thursday night (fixed lines,
/// FR-19).
class WeeklyReviewCard extends ConsumerWidget {
  const WeeklyReviewCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = watchToday(ref);
    final friday = lastFriday(today);
    final c = weekCounts(
      today: friday,
      completions: ref.watch(completionsProvider).value ?? const {},
      excused: ref.watch(excusedDaysProvider).value ?? const {},
      prayers: ref.watch(prayerLogsProvider).value ?? const {},
      moods: ref.watch(moodsProvider).value ?? const {},
      journalDays: (ref.watch(journalsProvider).value ?? const {}).keys.toSet(),
    );
    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 15))),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
    return NCard(
      key: const Key('weekly-review'),
      color: AppColors.accent200,
      gap: 6,
      children: [
        Kicker('$weeklyTitle · ${weekRangeLabel(friday)}'),
        row(weeklyHabitsLabel, weeklyDays(c.habitDays, c.habitOf)),
        if (settingsOf(ref).showFaith) row(weeklyPrayersLabel, '${c.prayers}'),
        row(
          weeklyMoodLabel,
          weeklyMood(c.mostlyMood == null ? null : moodLabel(c.mostlyMood!)),
        ),
        row(weeklyJournalLabel, weeklyDays(c.journalDays, 7)),
        const SizedBox(height: 4),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: FilledButton(
            key: const Key('weekly-note'),
            onPressed: () => openJournal(context, ref, today),
            child: const Text(weeklyNoteLabel),
          ),
        ),
      ],
    );
  }
}
