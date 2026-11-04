import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/prayer/prayer.dart';
import '../../l10n/strings.dart';
import '../../widgets/common.dart';
import '../more/more_screen.dart';
import '../settings/settings_widgets.dart';

/// Fasts logged this Hijri month and this Hijri year.
({int month, int year, int makeups}) fastCounts(
  Map<String, String> fasts,
  DateTime today,
  int offset,
) {
  final h = hijriDate(today, offset: offset);
  var month = 0, year = 0, makeups = 0;
  for (final e in fasts.entries) {
    final p = e.key.split('-').map(int.parse).toList();
    final d = hijriDate(DateTime(p[0], p[1], p[2]), offset: offset);
    if (d.year != h.year) continue;
    year++;
    if (d.month == h.month) month++;
    if (e.value == 'makeup') makeups++;
  }
  return (month: month, year: year, makeups: makeups);
}

/// More → Fasting: today's fast, counts, and two private make-up counters.
/// The app never decides what is owed (a tracking aid, not a ruling).
class FastingScreen extends ConsumerWidget {
  const FastingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = watchToday(ref);
    final fasts = ref.watch(fastsProvider).value ?? const <String, String>{};
    final s = settingsOf(ref);
    final now = ref.read(clockProvider).now();
    final c = fastCounts(fasts, now, s.hijriOffset);
    final owedFasts = int.tryParse(s.raw['qadaFasts'] ?? '') ?? 0;
    final owedPrayers = int.tryParse(s.raw['qadaPrayers'] ?? '') ?? 0;
    final db = ref.read(databaseProvider);
    final kind = fasts[today];

    Future<void> setToday(String? k) async {
      // Logging a make-up fast takes one off the count you keep, and
      // un-logging it puts it back.
      if (k == 'makeup' && kind != 'makeup' && owedFasts > 0) {
        await ref.putSetting('qadaFasts', '${owedFasts - 1}');
      } else if (kind == 'makeup' && k != 'makeup') {
        await ref.putSetting('qadaFasts', '${owedFasts + 1}');
      }
      await db.setFast(today, k, now);
    }

    return ScreenBody(
      children: [
        const MoreTitle('Fasting'),
        NCard(
          gap: 10,
          children: [
            const Kicker('Today'),
            SettingChoice<String>(
              key: const Key('fast-today'),
              value: kind ?? 'none',
              options: const {
                'none': 'Not fasting',
                'fast': 'Fasting',
                'makeup': 'Make-up fast',
              },
              onChanged: (v) => setToday(v == 'none' ? null : v),
            ),
            Tr(
              'This Hijri month: {0} · this Hijri year: {1}',
              args: [c.month, c.year],
              style: meta(size: 13),
            ),
          ],
        ),
        NCard(
          gap: 10,
          children: [
            const CardTitle('Make-up counts'),
            const Note(
              'Private counters you keep yourself. Ask a scholar about what you owe.',
            ),
            _Counter(
              keyName: 'qada-fasts',
              label: 'Fasts to make up',
              value: owedFasts,
              onChanged: (n) => ref.putSetting('qadaFasts', '$n'),
            ),
            if (c.makeups > 0)
              Note(tr('{0} made up this Hijri year', [c.makeups])),
            _Counter(
              keyName: 'qada-prayers',
              label: 'Prayers to make up',
              value: owedPrayers,
              onChanged: (n) => ref.putSetting('qadaPrayers', '$n'),
            ),
          ],
        ),
      ],
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.keyName,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String keyName;
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Tr(label, style: const TextStyle(fontSize: 15))),
      RoundIconButton(
        icon: Icons.remove,
        label: 'One less',
        onPressed: value == 0 ? null : () => onChanged(value - 1),
      ),
      SizedBox(
        width: 48,
        child: Text(
          '$value',
          key: Key('$keyName-value'),
          textAlign: TextAlign.center,
          style: heading(22),
        ),
      ),
      RoundIconButton(
        icon: Icons.add,
        label: 'One more',
        onPressed: () => onChanged(value + 1),
      ),
    ],
  );
}
