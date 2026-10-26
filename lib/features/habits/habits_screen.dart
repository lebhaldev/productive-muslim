import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/day_key.dart';
import '../../core/streak.dart';
import '../../data/db/database.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import '../../l10n/app_localizations.dart';
import '../today/today_screen.dart' show TodayBar, todaySegments;

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
    final excused = ref.watch(excusedDaysProvider).value ?? const <String>{};
    final settings = settingsOf(ref);

    final segments = todaySegments(ref, today);
    final doneToday = segments.where((d) => d).length;
    final isExcused = excused.contains(today);

    return ScreenBody(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ScreenTitle('Habits'),
            if (segments.isNotEmpty) ...[
              Text(
                isExcused
                    ? AppLocalizations.of(context).excusedToday
                    : AppLocalizations.of(context)
                          .nOfMToday(doneToday, segments.length),
                key: const Key('habits-today-count'),
                style: meta(size: 14),
              ),
              if (!isExcused) ...[
                const SizedBox(height: 10),
                TodayBar(segments: segments),
              ],
            ],
          ],
        ),
        if (settings.showFaith && !settings.consistencyCardClosed)
          const _ConsistencyHadithCard(),
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
          _HabitCard(
            habit: h,
            days: done[h.id] ?? const {},
            today: today,
            excused: excused,
            showConsistency: settings.showConsistency,
          ),
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
    required this.excused,
    required this.showConsistency,
  });
  final Habit habit;
  final Set<String> days;
  final String today;
  final Set<String> excused;
  final bool showConsistency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(databaseProvider);
    return NCard(
      gap: 10,
      children: [
        Row(
          children: [
            Expanded(child: CardTitle(habit.name)),
            if (showConsistency)
              Flexible(
                child: Text(
                  consistencyTag(consistency(days, today, excused)),
                  style: meta(size: 12, color: AppColors.neutral800),
                  textAlign: TextAlign.end,
                ),
              ),
            PopupMenuButton<String>(
              key: Key('habit-menu-${habit.id}'),
              tooltip: 'More for ${habit.name}',
              icon: const Icon(Icons.more_horiz, size: 20),
              onSelected: (v) => switch (v) {
                'reminder' => _pickReminder(context, ref),
                'up' => db.moveUp(habit.id),
                'archive' => db.setArchived(habit.id, true),
                _ => _confirmDelete(context, ref),
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'reminder',
                  child: Text(
                    habit.reminderTime == null
                        ? 'Add a reminder'
                        : 'Reminder ${habit.reminderTime}',
                  ),
                ),
                const PopupMenuItem(value: 'up', child: Text('Move up')),
                const PopupMenuItem(value: 'archive', child: Text('Archive')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
        Row(
          children: [
            for (var back = 6; back >= 0; back--) ...[
              if (back < 6) const SizedBox(width: 6),
              Expanded(
                child: _DayRing(
                  habit: habit,
                  day: shiftDay(today, -back),
                  isToday: back == 0,
                  done: days.contains(shiftDay(today, -back)),
                ),
              ),
            ],
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

/// Shown once, until closed (FR-17): the hadith exactly as in the bundled
/// dataset, with its reference and no app sentence about the user's numbers.
class _ConsistencyHadithCard extends ConsumerWidget {
  const _ConsistencyHadithCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final h = ref.watch(consistencyHadithProvider).value;
    if (h == null) return const SizedBox.shrink();
    return NCard(
      key: const Key('consistency-hadith'),
      color: AppColors.sage200,
      gap: 10,
      children: [
        Row(
          children: [
            const Expanded(child: Kicker('On small deeds')),
            IconButton(
              key: const Key('consistency-hadith-close'),
              tooltip: 'Close',
              visualDensity: VisualDensity.compact,
              onPressed: () => ref
                  .read(databaseProvider)
                  .putSetting('consistencyCard', 'closed'),
              icon: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
        if (h.arabic != null) ArabicBlock(h.arabic!, size: 19),
        Text(h.text, style: const TextStyle(fontSize: 15, height: 1.5)),
        Text('${h.source} · ${h.translator}', style: meta()),
      ],
    );
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
        borderRadius: BorderRadius.circular(AppRadii.pill),
        onTap: () => ref.read(databaseProvider).toggleCompletion(habit.id, day),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: TickBurst(
            on: done,
            color: AppColors.sage600,
            child: AnimatedContainer(
              duration: motion(context, Motion.medium),
              curve: Curves.easeOutBack,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadii.pill),
                color: done ? AppColors.sage600 : Colors.transparent,
                border: Border.all(color: AppColors.sage600, width: 2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
