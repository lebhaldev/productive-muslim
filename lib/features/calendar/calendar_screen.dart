import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/day_key.dart';
import '../../core/moods.dart';
import '../../widgets/common.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  int monthOffset = 0;

  @override
  Widget build(BuildContext context) {
    final today = watchToday(ref);
    final t = parseDayKey(today);
    final month = DateTime(t.year, t.month + monthOffset, 1);
    final sel = ref.watch(selectedDayProvider);
    final moods = ref.watch(moodsProvider).value ?? const {};
    final journals = ref.watch(journalsProvider).value ?? const {};
    final habits = ref.watch(habitsProvider).value ?? const [];
    final done = ref.watch(completionsProvider).value ?? const {};
    final acts =
        (ref.watch(activitiesProvider).value ?? const [])
            .where((a) => a.dayKey == sel)
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));

    final lead = (month.weekday + 6) % 7; // Monday first
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final selMood = moods[sel];
    final selJournal = journals[sel];
    final selHabits = habits
        .where((h) => done[h.id]?.contains(sel) ?? false)
        .map((h) => h.name)
        .toList();

    return ScreenBody(
      children: [
        ScreenTitle(
          DateFormat('MMMM y').format(month),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RoundIconButton(
                icon: Icons.chevron_left,
                label: 'Previous month',
                onPressed: () => setState(() => monthOffset--),
              ),
              const SizedBox(width: 8),
              RoundIconButton(
                icon: Icons.chevron_right,
                label: 'Next month',
                onPressed: monthOffset < 0
                    ? () => setState(() => monthOffset++)
                    : null,
              ),
            ],
          ),
        ),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 0.85,
          children: [
            for (final d in const ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
              Center(
                child: ExcludeSemantics(child: Text(d, style: meta(size: 11))),
              ),
            for (var i = 0; i < lead; i++) const SizedBox.shrink(),
            for (var d = 1; d <= daysInMonth; d++)
              _DayCell(
                day: dayKey(DateTime(month.year, month.month, d, 12)),
                number: d,
                today: today,
                selected: sel,
                mood: moods[dayKey(DateTime(month.year, month.month, d, 12))],
                hasJournal: journals.containsKey(
                  dayKey(DateTime(month.year, month.month, d, 12)),
                ),
              ),
          ],
        ),
        Wrap(
          spacing: 14,
          children: [
            Text('● mood', style: meta(size: 11)),
            Text('• journal', style: meta(size: 11)),
          ],
        ),
        NCard(
          gap: 10,
          children: [
            Row(
              children: [
                Expanded(
                  child: CardTitle(
                    DateFormat('EEE d MMMM').format(parseDayKey(sel)),
                  ),
                ),
                Tag(
                  selMood == null ? 'No mood' : moodLabel(selMood),
                  sage: true,
                ),
              ],
            ),
            Text('Journal', style: meta()),
            Text(
              selJournal == null
                  ? 'No entry for this day.'
                  : '${selJournal.title.isEmpty ? '' : '${selJournal.title} — '}${selJournal.body}',
              style: const TextStyle(fontSize: 14),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton(
                onPressed: () => openJournal(context, ref, sel),
                child: const Text('Open journal'),
              ),
            ),
            Text('Habits completed', style: meta()),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final h in selHabits.isEmpty ? ['None'] : selHabits)
                  Tag(h, sage: true),
              ],
            ),
            Text('Activities', style: meta()),
            if (acts.isEmpty)
              const Text('None logged', style: TextStyle(fontSize: 14)),
            for (final a in acts)
              Text(
                '${a.startTime}  ${a.title} · ${a.durationMinutes} min',
                style: const TextStyle(fontSize: 14),
              ),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends ConsumerWidget {
  const _DayCell({
    required this.day,
    required this.number,
    required this.today,
    required this.selected,
    required this.mood,
    required this.hasJournal,
  });

  final String day;
  final int number;
  final String today;
  final String selected;
  final int? mood;
  final bool hasJournal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final future = day.compareTo(today) > 0;
    final isToday = day == today;
    final label = [
      DateFormat('EEEE d MMMM').format(parseDayKey(day)),
      if (mood != null) 'mood ${moodLabel(mood!)}',
      if (hasJournal) 'has journal',
    ].join(', ');
    return Semantics(
      button: !future,
      selected: day == selected,
      label: label,
      excludeSemantics: true,
      child: Opacity(
        opacity: future ? 0.4 : 1,
        child: Material(
          color: day == selected ? AppColors.sage200 : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: isToday
                ? const BorderSide(color: AppColors.sage600, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: future
                ? null
                : () => ref.read(selectedDayProvider.notifier).set(day),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: 8,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _dot(
                        8,
                        mood == null
                            ? Colors.transparent
                            : AppColors.moods[mood!],
                      ),
                      const SizedBox(width: 3),
                      _dot(4, hasJournal ? AppColors.text : Colors.transparent),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dot(double size, Color color) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}
