import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/day_key.dart';
import '../../core/moods.dart';

/// Monday to Sunday of [today]'s week.
List<String> weekOf(String today) {
  final back = parseDayKey(today).weekday - 1;
  return [for (var i = 0; i < 7; i++) shiftDay(today, i - back)];
}

/// Seven mood dots for this week; tapping a past day opens it in Calendar.
class MoodWeekStrip extends ConsumerWidget {
  const MoodWeekStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = watchToday(ref);
    final moods = ref.watch(moodsProvider).value ?? const {};
    return Row(
      key: const Key('mood-week'),
      children: [
        for (final d in weekOf(today))
          Expanded(
            child: _WeekDot(
              day: d,
              mood: moods[d],
              isToday: d == today,
              future: d.compareTo(today) > 0,
            ),
          ),
      ],
    );
  }
}

class _WeekDot extends ConsumerWidget {
  const _WeekDot({
    required this.day,
    required this.mood,
    required this.isToday,
    required this.future,
  });
  final String day;
  final int? mood;
  final bool isToday;
  final bool future;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = parseDayKey(day);
    return Semantics(
      container: true,
      button: !future,
      label:
          '${DateFormat('EEEE d MMMM').format(date)} '
          '${mood == null ? 'no mood' : moodLabel(mood!)}',
      excludeSemantics: true,
      child: InkWell(
        key: Key('mood-week-$day'),
        customBorder: const CircleBorder(),
        onTap: future
            ? null
            : () {
                ref.read(selectedDayProvider.notifier).set(day);
                context.go('/calendar');
              },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mood == null ? null : AppColors.moods[mood!],
                  border: mood == null
                      ? Border.all(
                          color: future
                              ? AppColors.divider
                              : AppColors.neutral300,
                          width: 1.5,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                DateFormat('EEE').format(date),
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: meta(size: 11).copyWith(
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 18,
                height: 2,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.sage600 : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
