import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/day_key.dart';
import '../../core/moods.dart';
import '../../core/streak.dart';
import '../../data/prayer/prayer.dart';
import '../../data/weather/weather.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import '../prayer/prayer_screen.dart';
import 'content_cards.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = watchToday(ref);
    final settings = settingsOf(ref);
    final now = ref.read(clockProvider).now();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dailyContentProvider);
        ref.invalidate(weatherProvider);
        await ref.read(weatherProvider.future);
      },
      child: ScreenBody(
        gap: 18,
        children: [
          _Header(date: parseDayKey(today), hour: now.hour),
          if (settings.showFaith) const PrayerCard(),
          if (settings.showFaith) const ContentCards(),
          _HabitsSection(today: today),
          _MoodSection(today: today),
          _ActivitySection(today: today),
          _JournalShortcut(today: today),
          const _CacheNote(),
        ],
      ),
    );
  }
}

String greetingFor(int hour) {
  if (hour < 12) return 'Good morning';
  if (hour < 18) return 'Good afternoon';
  return 'Good evening';
}

class _Header extends ConsumerWidget {
  const _Header({required this.date, required this.hour});
  final DateTime date;
  final int hour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE d MMMM').format(date),
                style: meta(size: 13),
              ),
              Text(hijriLabel(date), style: meta(size: 13)),
              const SizedBox(height: 2),
              Semantics(
                container: true,
                header: true,
                child: Text(greetingFor(hour), style: heading(28)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        const Flexible(child: _WeatherChip()),
      ],
    );
  }
}

class _WeatherChip extends ConsumerWidget {
  const _WeatherChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = settingsOf(ref);
    final wx = ref.watch(weatherProvider).value;
    final w = wx?.weather;
    final color = AppColors.sage900;
    return Material(
      color: AppColors.sage200,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: w == null ? () => context.go('/more/settings') : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: w == null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('—', style: heading(24, color: color)),
                    Text(
                      wx?.error ?? 'Loading weather',
                      style: TextStyle(fontSize: 11, color: color),
                      textAlign: TextAlign.right,
                    ),
                  ],
                )
              : Semantics(
                  container: true,
                  label:
                      'Weather ${w.place}: ${formatTemp(w.nowC, fahrenheit: s.fahrenheit)}, '
                      '${w.condition}',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatTemp(w.nowC, fahrenheit: s.fahrenheit),
                        style: heading(24, color: color),
                      ),
                      Text(
                        'H ${formatTemp(w.hiC, fahrenheit: s.fahrenheit)} · '
                        'L ${formatTemp(w.loC, fahrenheit: s.fahrenheit)}',
                        style: TextStyle(fontSize: 11, color: color),
                        textAlign: TextAlign.right,
                      ),
                      Text(
                        '${w.condition} · ${w.place}',
                        style: TextStyle(fontSize: 11, color: color),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, {this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Expanded(
        child: Semantics(
          container: true,
          header: true,
          child: Text(title, style: heading(19)),
        ),
      ),
      ?trailing,
    ],
  );
}

class _HabitsSection extends ConsumerWidget {
  const _HabitsSection({required this.today});
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = (ref.watch(habitsProvider).value ?? const [])
        .where((h) => !h.archived)
        .toList();
    final done = ref.watch(completionsProvider).value ?? const {};
    final doneCount = habits
        .where((h) => done[h.id]?.contains(today) ?? false)
        .length;
    final db = ref.read(databaseProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          'Habits',
          trailing: PopSwitcher(
            child: habits.isNotEmpty && doneCount == habits.length
                ? Text(
                    'All done today',
                    key: const ValueKey('all-done'),
                    style: meta(color: AppColors.sage900)
                        .copyWith(fontWeight: FontWeight.w600),
                  )
                : Text(
                    '$doneCount of ${habits.length}',
                    key: ValueKey(doneCount),
                    style: meta(),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        if (habits.isEmpty)
          TextButton(
            style: TextButton.styleFrom(alignment: Alignment.centerLeft),
            onPressed: () => context.go('/habits'),
            child: const Text('Add your first habit'),
          ),
        for (final h in habits) ...[
          _HabitRow(
            name: h.name,
            done: done[h.id]?.contains(today) ?? false,
            streak: streak(done[h.id] ?? const {}, today),
            onTap: () => db.toggleCompletion(h.id, today),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({
    required this.name,
    required this.done,
    required this.streak,
    required this.onTap,
  });
  final String name;
  final bool done;
  final int streak;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      checked: done,
      label: '${done ? 'Undo' : 'Mark done'} $name',
      excludeSemantics: true,
      child: Material(
        color: AppColors.surface,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: PopSwitcher(
                      child: done
                          ? Container(
                              key: const ValueKey('done'),
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: AppColors.sage600,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                size: 17,
                                color: AppColors.bg,
                              ),
                            )
                          : Container(
                              key: const ValueKey('open'),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.neutral600,
                                  width: 2,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(name, style: const TextStyle(fontSize: 15)),
                  ),
                  PopSwitcher(
                    child: Text(
                      streakLabel(streak),
                      key: ValueKey(streak),
                      style: meta(color: AppColors.accent700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodSection extends ConsumerWidget {
  const _MoodSection({required this.today});
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(moodsProvider).value?[today];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeader('How do you feel?'),
        const SizedBox(height: 8),
        Row(
          children: [
            for (final m in MoodLevel.values)
              Expanded(
                child: MoodDot(
                  value: m.index,
                  selected: current == m.index,
                  onTap: () => ref
                      .read(databaseProvider)
                      .setMood(today, m.index, ref.read(clockProvider).now()),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class MoodDot extends StatelessWidget {
  const MoodDot({
    super.key,
    required this.value,
    required this.selected,
    required this.onTap,
  });
  final int value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = selected ? 40.0 : 32.0;
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: 'Mood ${moodLabel(value)}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: AppColors.moods[value],
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: AppColors.bg, width: 3)
                          : null,
                      boxShadow: selected
                          ? [BoxShadow(color: AppColors.text, spreadRadius: 2)]
                          : null,
                    ),
                  ),
                ),
              ),
              Text(
                moodLabel(value),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivitySection extends ConsumerWidget {
  const _ActivitySection({required this.today});
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acts =
        (ref.watch(activitiesProvider).value ?? const [])
            .where((a) => a.dayKey == today)
            .toList()
          ..sort((a, b) => a.startTime.compareTo(b.startTime));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          'Today’s activity',
          trailing: TextButton(
            onPressed: () => context.go('/more/activities'),
            child: const Text('+ Log'),
          ),
        ),
        if (acts.isEmpty) Text('Nothing logged yet.', style: meta(size: 13)),
        for (final a in acts)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                SizedBox(width: 56, child: Text(a.startTime, style: meta())),
                Expanded(
                  child: Text(a.title, style: const TextStyle(fontSize: 15)),
                ),
                Text('${a.durationMinutes} min', style: meta()),
              ],
            ),
          ),
      ],
    );
  }
}

class _JournalShortcut extends ConsumerWidget {
  const _JournalShortcut({required this.today});
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final j = ref.watch(journalsProvider).value?[today];
    final locked = ref.watch(journalLockedProvider);
    final sub = locked && j != null
        ? 'Written today · locked'
        : j == null
        ? 'A few lines is enough.'
        : (j.title.isNotEmpty
              ? j.title
              : '${j.body.length > 40 ? j.body.substring(0, 40) : j.body}…');
    return Material(
      color: AppColors.accent200,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        onTap: () => openJournal(context, ref, today),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                j == null
                    ? 'Write today’s journal'
                    : 'Continue today’s journal',
                style: heading(19, color: AppColors.accent900),
              ),
              const SizedBox(height: 4),
              Text(
                sub,
                style: TextStyle(fontSize: 13, color: AppColors.accent900),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CacheNote extends ConsumerWidget {
  const _CacheNote();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(dailyContentProvider).value;
    final weather = ref.watch(weatherProvider).value;
    final times = [
      content?.ayah.fetchedAt,
      weather?.fetchedAt,
    ].whereType<DateTime>().toList()..sort();
    if (times.isEmpty) {
      return Text(
        'Works offline after the first update',
        style: meta(size: 11),
      );
    }
    return Text(
      'Content and weather updated ${DateFormat('HH:mm').format(times.first)} · works offline',
      style: meta(size: 11),
    );
  }
}
