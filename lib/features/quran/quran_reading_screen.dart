import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/day_key.dart';
import '../../l10n/strings.dart';
import '../../widgets/common.dart';
import '../more/more_screen.dart';
import '../settings/settings_widgets.dart';

/// Pages in the Madani mushaf, used for khatm progress.
const mushafPages = 604;

/// Pages per juz in the Madani mushaf, on average (604 / 30).
const pagesPerJuz = 604 / 30;

/// Progress of the current khatm from the logged pages.
({int read, int left, double juz}) khatmProgress(
  Map<String, int> reads,
  String? start,
) {
  final read = reads.entries
      .where((e) => start == null || e.key.compareTo(start) >= 0)
      .fold<int>(0, (t, e) => t + e.value)
      .clamp(0, mushafPages);
  return (read: read, left: mushafPages - read, juz: read / pagesPerJuz);
}

/// Pages a day needed to finish [left] pages by [goal], counting today.
int pagesPerDayFor(int left, String today, String goal) {
  final days = parseDayKey(goal).difference(parseDayKey(today)).inDays + 1;
  if (days <= 0) return left;
  return (left / days).ceil();
}

/// More → Quran reading: pages read per day and progress of the current
/// khatm. A tracker only; there is no Qur'an reader in the app.
class QuranReadingScreen extends ConsumerWidget {
  const QuranReadingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = watchToday(ref);
    final reads = ref.watch(quranReadsProvider).value ?? const <String, int>{};
    final s = settingsOf(ref).raw;
    String? key(String k) => (s[k] ?? '').isEmpty ? null : s[k];
    final start = key('khatmStart');
    final goal = key('khatmGoal');
    final todayPages = reads[today] ?? 0;
    final p = khatmProgress(reads, start);
    final db = ref.read(databaseProvider);
    final now = ref.read(clockProvider).now;

    Future<void> setPages(int n) =>
        db.setQuranPages(today, n.clamp(0, mushafPages), now());

    return ScreenBody(
      children: [
        const MoreTitle('Quran reading'),
        NCard(
          gap: 10,
          children: [
            const Kicker('Today'),
            Row(
              children: [
                RoundIconButton(
                  icon: Icons.remove,
                  label: 'One page less',
                  onPressed: todayPages == 0
                      ? null
                      : () => setPages(todayPages - 1),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '$todayPages',
                        key: const Key('quran-today'),
                        style: heading(44),
                      ),
                      Tr(todayPages == 1 ? 'page' : 'pages', style: meta()),
                    ],
                  ),
                ),
                RoundIconButton(
                  icon: Icons.add,
                  label: 'One page more',
                  onPressed: () => setPages(todayPages + 1),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (final (n, label) in const [
                  (5, '+5'),
                  (10, '+10'),
                  (20, '+1 juz'),
                ])
                  OutlinedButton(
                    key: Key('quran-add-$n'),
                    onPressed: () => setPages(todayPages + n),
                    child: Tr(label),
                  ),
              ],
            ),
          ],
        ),
        NCard(
          gap: 10,
          children: [
            const Kicker('Khatm'),
            Tr(
              '{0} of {1} pages · about juz {2}',
              args: [p.read, mushafPages, p.juz.floor().clamp(0, 30)],
              style: const TextStyle(fontSize: 15),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.pill),
              child: LinearProgressIndicator(
                key: const Key('khatm-bar'),
                value: p.read / mushafPages,
                minHeight: 10,
                color: AppColors.sage600,
                backgroundColor: AppColors.neutral200,
              ),
            ),
            if (start != null)
              Note(
                tr('Started {0}', [
                  DateFormat('d MMM y').format(parseDayKey(start)),
                ]),
              ),
            if (goal != null && p.left > 0)
              Note(
                tr('Finish by {0}: about {1} pages a day', [
                  DateFormat('d MMM').format(parseDayKey(goal)),
                  pagesPerDayFor(p.left, today, goal),
                ]),
              ),
            if (p.left == 0)
              const Note('Khatm complete. Start a new one when you are ready.'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  key: const Key('khatm-goal'),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: parseDayKey(today),
                      lastDate: parseDayKey(today)
                          .add(const Duration(days: 730)),
                      initialDate: goal == null
                          ? parseDayKey(today).add(const Duration(days: 30))
                          : parseDayKey(goal),
                    );
                    if (picked != null) {
                      await ref.putSetting('khatmGoal', dayKey(picked));
                    }
                  },
                  child: Tr(goal == null ? 'Set a finish date' : 'Change date'),
                ),
                TextButton(
                  key: const Key('khatm-new'),
                  onPressed: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Tr('Start a new khatm?'),
                        content: const Tr(
                          'Progress counts from today. Your reading log is kept.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(c, false),
                            child: const Tr('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(c, true),
                            child: const Tr('Start'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await ref.putSetting('khatmStart', today);
                      await ref.putSetting('khatmGoal', '');
                    }
                  },
                  child: const Tr('Start a new khatm'),
                ),
              ],
            ),
          ],
        ),
        NCard(
          gap: 8,
          children: [
            const Kicker('Last 7 days'),
            _WeekBars(reads: reads, today: today),
          ],
        ),
        const Note('A tracker only. Read in your own mushaf or Quran app.'),
      ],
    );
  }
}

class _WeekBars extends StatelessWidget {
  const _WeekBars({required this.reads, required this.today});
  final Map<String, int> reads;
  final String today;

  @override
  Widget build(BuildContext context) {
    final days = [for (var i = 6; i >= 0; i--) shiftDay(today, -i)];
    final most = days
        .map((d) => reads[d] ?? 0)
        .fold<int>(1, (a, b) => b > a ? b : a);
    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final d in days)
            Expanded(
              child: Semantics(
                label: tr('{0}: {1} pages', [
                  DateFormat('EEEE').format(parseDayKey(d)),
                  reads[d] ?? 0,
                ]),
                excludeSemantics: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('${reads[d] ?? 0}', style: meta(size: 11)),
                    const SizedBox(height: 2),
                    Container(
                      height: 56 * (reads[d] ?? 0) / most + 2,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: d == today
                            ? AppColors.accent700
                            : AppColors.sage400,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('E').format(parseDayKey(d)),
                      style: meta(size: 10),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
