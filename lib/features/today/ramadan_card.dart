import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/prayer/prayer.dart';
import '../../l10n/strings.dart';
import '../../widgets/common.dart';

/// Today in Ramadan (Umm al-Qura with the user's Hijri offset): when suhoor
/// ends (Fajr) and iftar (Maghrib), the time left to the next one, and a
/// switch to log today's fast. Hidden outside Ramadan.
class RamadanCard extends ConsumerWidget {
  const RamadanCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = settingsOf(ref);
    final now =
        ref.watch(minuteProvider).value ?? ref.read(clockProvider).now();
    final h = hijriDate(now, offset: s.hijriOffset);
    if (h.month != 9) return const SizedBox.shrink();
    final today = watchToday(ref);
    final day = ref.watch(prayerDayProvider(today));
    final fasting = ref.watch(fastsProvider).value?[today] != null;
    String t(DateTime d) => DateFormat('HH:mm').format(d);
    final fajr = day?[PrayerName.fajr];
    final maghrib = day?[PrayerName.maghrib];
    final String? countdown = switch ((fajr, maghrib)) {
      (final f?, _) when now.isBefore(f) => tr('Suhoor ends {0}', [
        untilLabel(f.difference(now)),
      ]),
      (_, final m?) when now.isBefore(m) => tr('Iftar {0}', [
        untilLabel(m.difference(now)),
      ]),
      _ => null,
    };
    return NCard(
      key: const Key('ramadan-card'),
      color: AppColors.accent200,
      gap: 8,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                tr('Ramadan · day {0}', [h.day]),
                style: heading(19, color: AppColors.accent900),
              ),
            ),
            if (countdown != null)
              Text(countdown, style: meta(color: AppColors.accent900)),
          ],
        ),
        if (fajr != null && maghrib != null)
          Row(
            children: [
              Expanded(
                child: _Time(label: 'Suhoor ends', time: t(fajr)),
              ),
              Expanded(
                child: _Time(label: 'Iftar', time: t(maghrib)),
              ),
            ],
          )
        else
          const Note(
            'Set your city in Settings to see suhoor and iftar times.',
          ),
        SwitchListTile(
          key: const Key('ramadan-fasting'),
          contentPadding: EdgeInsets.zero,
          title: const Tr('Fasting today', style: TextStyle(fontSize: 15)),
          value: fasting,
          activeTrackColor: AppColors.sage600,
          onChanged: (v) => ref
              .read(databaseProvider)
              .setFast(today, v ? 'fast' : null, ref.read(clockProvider).now()),
        ),
      ],
    );
  }
}

class _Time extends StatelessWidget {
  const _Time({required this.label, required this.time});
  final String label;
  final String time;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Tr(label, style: meta(color: AppColors.accent900)),
      Text(time, style: heading(22, color: AppColors.accent900)),
    ],
  );
}
