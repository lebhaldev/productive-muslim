import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/day_key.dart';
import '../../core/streak.dart';
import '../../data/db/database.dart';
import '../../widgets/common.dart';

class HabitsScreen extends ConsumerStatefulWidget {
  const HabitsScreen({super.key});

  @override
  ConsumerState<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends ConsumerState<HabitsScreen> {
  final _draft = TextEditingController();

  @override
  void dispose() {
    _draft.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final name = _draft.text.trim();
    if (name.isEmpty) return;
    await ref.read(databaseProvider).addHabit(name);
    _draft.clear();
  }

  @override
  Widget build(BuildContext context) {
    final today = watchToday(ref);
    final all = ref.watch(habitsProvider).value ?? const <Habit>[];
    final active = all.where((h) => !h.archived).toList();
    final archived = all.where((h) => h.archived).toList();
    final done = ref.watch(completionsProvider).value ?? const {};

    return ScreenBody(
      children: [
        const ScreenTitle('Habits'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _draft,
                decoration: const InputDecoration(hintText: 'New habit'),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(onPressed: _add, child: const Text('Add')),
          ],
        ),
        if (active.isEmpty)
          Text(
            'No habits yet. Add one above, like “Read Quran 10 min”.',
            style: meta(size: 13),
          ),
        for (final h in active)
          _HabitCard(habit: h, days: done[h.id] ?? const {}, today: today),
        if (archived.isNotEmpty) ...[
          Text('Archived', style: meta(size: 13)),
          for (final h in archived)
            Container(
              padding: const EdgeInsets.fromLTRB(14, 4, 4, 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      h.name,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.neutral800,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(databaseProvider).setArchived(h.id, false),
                    child: const Text('Restore'),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

class _HabitCard extends ConsumerWidget {
  const _HabitCard({
    required this.habit,
    required this.days,
    required this.today,
  });
  final Habit habit;
  final Set<String> days;
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    final n = streak(days, today);
    return NCard(
      gap: 10,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: CardTitle(habit.name)),
            Tag(streakTag(n)),
          ],
        ),
        Row(
          children: [
            for (var back = 6; back >= 0; back--)
              Expanded(
                child: _DayRing(
                  habit: habit,
                  day: shiftDay(today, -back),
                  isToday: back == 0,
                  done: days.contains(shiftDay(today, -back)),
                ),
              ),
          ],
        ),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.neutral700,
                padding: EdgeInsets.zero,
              ),
              onPressed: () => _pickReminder(context, ref),
              child: Text(
                habit.reminderTime == null
                    ? 'No reminder'
                    : 'Reminder ${habit.reminderTime}',
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              tooltip: 'Move up',
              onPressed: () => db.moveUp(habit.id),
              icon: const Icon(Icons.arrow_upward, size: 18),
            ),
            TextButton(
              onPressed: () => db.setArchived(habit.id, true),
              child: const Text('Archive'),
            ),
            TextButton(
              onPressed: () => _confirmDelete(context, ref),
              child: const Text('Delete'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickReminder(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: habit.reminderTime == null
          ? const TimeOfDay(hour: 8, minute: 0)
          : parseHhmm(habit.reminderTime!),
      helpText: 'Reminder for ${habit.name}',
      cancelText: habit.reminderTime == null ? 'Cancel' : 'Remove',
    );
    if (picked != null) {
      final allowed = await ref
          .read(reminderSchedulerProvider)
          .requestPermission();
      if (!allowed) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Notifications are off for Nurday. Allow them in Android settings to get reminders.',
              ),
            ),
          );
        }
        return;
      }
      await db.setReminder(habit.id, hhmm(picked));
    } else if (habit.reminderTime != null) {
      await db.setReminder(habit.id, null);
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Delete “${habit.name}”?'),
        content: const Text(
          'Its history is removed too. Archive keeps the history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) await ref.read(databaseProvider).deleteHabit(habit.id);
  }
}

class _DayRing extends ConsumerWidget {
  const _DayRing({
    required this.habit,
    required this.day,
    required this.isToday,
    required this.done,
  });
  final Habit habit;
  final String day;
  final bool isToday;
  final bool done;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = parseDayKey(day);
    return Semantics(
      container: true,
      button: true,
      checked: done,
      label:
          '${habit.name} ${DateFormat('EEEE d MMMM').format(date)} ${done ? 'done' : 'not done'}',
      excludeSemantics: true,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => ref.read(databaseProvider).toggleCompletion(habit.id, day),
        child: Column(
          children: [
            Text(
              isToday ? 'Today' : DateFormat('EEEEE').format(date),
              style: meta(size: 10),
            ),
            const SizedBox(height: 3),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppColors.sage600 : Colors.transparent,
                border: Border.all(color: AppColors.sage600, width: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
