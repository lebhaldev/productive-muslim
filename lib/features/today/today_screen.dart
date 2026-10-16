import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../app/theme.dart';
import '../../core/copy.dart';
import '../../core/day_key.dart';
import '../../core/moods.dart';
import '../../core/streak.dart';
import '../../data/prayer/prayer.dart';
import '../../l10n/app_localizations.dart';
import '../../data/weather/weather.dart';
import '../../widgets/common.dart';
import '../../widgets/motion.dart';
import '../prayer/prayer_screen.dart';
import 'content_cards.dart';
import 'mood_week.dart';

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _JournalShortcut(today: today)),
              const SizedBox(width: 10),
              Expanded(child: _ActivityTile(today: today)),
            ],
          ),
        ],
      ),
    );
  }
}

String greetingFor(int hour, [AppLocalizations? l]) {
  if (hour < 12) return l?.greetingMorning ?? 'Good morning';
  if (hour < 18) return l?.greetingAfternoon ?? 'Good afternoon';
  return l?.greetingEvening ?? 'Good evening';
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
                '${DateFormat('EEE d MMM').format(date)} · ${hijriLabel(date, offset: settingsOf(ref).hijriOffset)}',
                style: meta(size: 13),
              ),
              const SizedBox(height: 2),
              Semantics(
                container: true,
                header: true,
                child: Text(
                  greetingFor(hour, AppLocalizations.of(context)),
                  style: heading(28),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const Flexible(child: _WeatherChip()),
        IconButton(
          key: const Key('open-settings'),
          tooltip: 'Settings',
          onPressed: () => context.push('/settings'),
          icon: Icon(Icons.settings_outlined, color: AppColors.neutral800),
        ),
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
        onTap: w == null ? () => context.push('/settings/location') : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    final excused = ref.watch(excusedDaysProvider).value ?? const <String>{};
    final settings = settingsOf(ref);
    final logged = settings.showFaith
        ? (ref.watch(prayerLogsProvider).value?[today] ?? const <String>{})
        : const <String>{};
    final isExcused = excused.contains(today);
    final l = AppLocalizations.of(context);
    final db = ref.read(databaseProvider);

    // One segment per habit, then one per prayer when faith cards are on
    // (FR-17): habits first, prayers after, done segments filled.
    final segments = [
      for (final h in habits) done[h.id]?.contains(today) ?? false,
      if (settings.showFaith)
        for (final p in fivePrayers) logged.contains(p.name),
    ];
    final doneCount = segments.where((d) => d).length;
    final all = segments.isNotEmpty && doneCount == segments.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          l.sectionHabits,
          trailing: PopSwitcher(
            child: isExcused
                ? Text(
                    l.excusedToday,
                    key: const ValueKey('excused'),
                    style: meta(),
                  )
                : all
                ? Text(
                    l.allDoneToday,
                    key: const ValueKey('all-done'),
                    style: meta(color: AppColors.sage900)
                        .copyWith(fontWeight: FontWeight.w600),
                  )
                : Text(
                    l.nOfMToday(doneCount, segments.length),
                    key: ValueKey(doneCount),
                    style: meta(),
                  ),
          ),
        ),
        if (segments.isNotEmpty && !isExcused) ...[
          const SizedBox(height: 8),
          TodayBar(segments: segments),
        ],
        const SizedBox(height: 8),
        if (habits.isEmpty)
          TextButton(
            style: TextButton.styleFrom(alignment: Alignment.centerLeft),
            onPressed: () => context.go('/habits'),
            child: Text(l.addFirstHabit),
          ),
        for (final h in habits) ...[
          _HabitRow(
            name: h.name,
            done: done[h.id]?.contains(today) ?? false,
            label: settings.showConsistency
                ? consistencyLabel(
                    consistency(done[h.id] ?? const {}, today, excused),
                  )
                : '',
            onTap: () => db.toggleCompletion(h.id, today),
          ),
          const SizedBox(height: 8),
        ],
        // FR-18: a neutral link, no reason asked or stored.
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            key: const Key('excused-today'),
            style: TextButton.styleFrom(foregroundColor: AppColors.neutral700),
            onPressed: () =>
                db.setExcused(today, !isExcused, ref.read(clockProvider).now()),
            child: Text(isExcused ? l.countTodayAgain : l.excusedToday),
          ),
        ),
      ],
    );
  }
}

/// `N of M today`: one rounded segment per habit and logged prayer.
class TodayBar extends StatelessWidget {
  const TodayBar({super.key, required this.segments});
  final List<bool> segments;

  @override
  Widget build(BuildContext context) {
    final n = segments.where((d) => d).length;
    return Semantics(
      label: '$n of ${segments.length} done today',
      excludeSemantics: true,
      child: Row(
        key: const Key('today-bar'),
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0) const SizedBox(width: 3),
            Expanded(
              child: AnimatedContainer(
                duration: motion(context, Motion.medium),
                height: 6,
                decoration: BoxDecoration(
                  color: segments[i] ? AppColors.sage600 : AppColors.divider,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HabitRow extends StatelessWidget {
  const _HabitRow({
    required this.name,
    required this.done,
    required this.label,
    required this.onTap,
  });
  final String name;
  final bool done;
  final String label;
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
                      label,
                      key: ValueKey(label),
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
    final hidden = settingsOf(ref).moodReplyHiddenOn == today;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(AppLocalizations.of(context).sectionMood),
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
        AnimatedSize(
          duration: motion(context, Motion.medium),
          alignment: Alignment.topCenter,
          child: current == null || hidden
              ? const SizedBox(width: double.infinity)
              : _MoodReply(today: today, mood: MoodLevel.values[current]),
        ),
        const SizedBox(height: 6),
        const MoodWeekStrip(),
      ],
    );
  }
}

/// FR-19: one fixed line and one suggestion for the picked mood.
class _MoodReply extends ConsumerWidget {
  const _MoodReply({required this.today, required this.mood});
  final String today;
  final MoodLevel mood;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reply = moodReplies[mood]!;
    final habits = (ref.watch(habitsProvider).value ?? const []).where(
      (h) => !h.archived,
    );
    final done = ref.watch(completionsProvider).value ?? const {};
    final open = habits
        .where((h) => !(done[h.id]?.contains(today) ?? false))
        .firstOrNull;
    final journal = (openJournalLabel, () => openJournal(context, ref, today));
    final (label, onPressed) = switch (reply.suggestion) {
      MoodSuggestion.journal => journal,
      MoodSuggestion.gratitude => (
        gratitudeLabel,
        () => openJournal(context, ref, today),
      ),
      // With no habit left open, fall back to the journal.
      MoodSuggestion.habit when open != null => (
        habitSuggestionLabel(open.name),
        () => ref.read(databaseProvider).toggleCompletion(open.id, today),
      ),
      MoodSuggestion.habit => journal,
    };
    return Padding(
      key: const Key('mood-reply'),
      padding: const EdgeInsets.only(top: 8),
      child: NCard(
        gap: 8,
        children: [
          Text(reply.line, style: const TextStyle(fontSize: 15)),
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.tonal(
                key: const Key('mood-suggestion'),
                onPressed: onPressed,
                child: Text(label),
              ),
              TextButton(
                key: const Key('mood-not-now'),
                onPressed: () => ref
                    .read(databaseProvider)
                    .putSetting('moodReplyHidden', today),
                child: const Text('Not now'),
              ),
            ],
          ),
        ],
      ),
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

class _ActivityTile extends ConsumerWidget {
  const _ActivityTile({required this.today});
  final String today;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acts = (ref.watch(activitiesProvider).value ?? const [])
        .where((a) => a.dayKey == today)
        .toList();
    final minutes = acts.fold<int>(0, (t, a) => t + a.durationMinutes);
    return ActionTile(
      key: const Key('activity-tile'),
      color: AppColors.sage200,
      ink: AppColors.sage900,
      icon: Icons.directions_walk,
      title: 'Activity',
      sub: acts.isEmpty
          ? 'Nothing logged yet'
          : '${acts.length} logged · $minutes min',
      onTap: () => context.go('/more/activities'),
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
        ? ''
        : j.title.isNotEmpty
        ? j.title
        : j.body.trim().isEmpty
        ? 'Gratitude written'
        : '${j.body.length > 40 ? j.body.substring(0, 40) : j.body}…';
    return ActionTile(
      key: const Key('journal-tile'),
      color: AppColors.accent200,
      ink: AppColors.accent900,
      icon: Icons.edit_outlined,
      title: 'Journal',
      sub: j == null ? 'Write a few lines' : sub,
      onTap: () => openJournal(context, ref, today),
    );
  }
}
