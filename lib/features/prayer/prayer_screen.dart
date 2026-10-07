import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/day_key.dart';
import '../../data/prayer/prayer.dart';
import '../../widgets/common.dart';
import '../more/more_screen.dart';

String _t(DateTime t) => DateFormat('HH:mm').format(t);

const _noLocation = 'Set your city in Settings to see prayer times.';

/// Today card: next prayer with a countdown and the day's times (FR-12).
class PrayerCard extends ConsumerWidget {
  const PrayerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = watchToday(ref);
    final now =
        ref.watch(minuteProvider).value ?? ref.read(clockProvider).now();
    final day = ref.watch(prayerDayProvider(today));
    final tomorrow = ref.watch(prayerDayProvider(shiftDay(today, 1)));
    if (day == null || tomorrow == null) {
      return NCard(
        onTap: () => context.push('/settings/location'),
        children: [
          const Kicker('Prayer times'),
          Text(_noLocation, style: meta(size: 13, color: AppColors.neutral800)),
        ],
      );
    }
    final next = nextPrayer(day, tomorrow, now);
    final label = prayerLabels[next.name]!;
    return NCard(
      onTap: () => context.go('/more/prayer'),
      children: [
        Row(
          children: [
            const Expanded(child: Kicker('Next prayer')),
            Flexible(
              child: Text(
                ref.watch(prayerLocationProvider)?.place ?? '',
                overflow: TextOverflow.ellipsis,
                style: meta(),
              ),
            ),
          ],
        ),
        Semantics(
          container: true,
          label:
              '$label at ${_t(next.at)}, ${untilLabel(next.at.difference(now))}',
          child: ExcludeSemantics(
            child: Wrap(
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                Text('$label ${_t(next.at)}', style: heading(22)),
                Text(
                  untilLabel(next.at.difference(now)),
                  style: meta(size: 13, color: AppColors.accent700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// More → Prayer times: today's times and the Qibla bearing.
class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = watchToday(ref);
    final now =
        ref.watch(minuteProvider).value ?? ref.read(clockProvider).now();
    final s = settingsOf(ref);
    final loc = ref.watch(prayerLocationProvider);
    final day = ref.watch(prayerDayProvider(today));
    final tomorrow = ref.watch(prayerDayProvider(shiftDay(today, 1)));
    if (loc == null || day == null || tomorrow == null) {
      return ScreenBody(
        children: [
          const MoreTitle('Prayer times'),
          NCard(
            children: [
              Text(
                _noLocation,
                style: meta(size: 14, color: AppColors.neutral800),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  onPressed: () => context.push('/settings/location'),
                  child: const Text('Open Settings'),
                ),
              ),
            ],
          ),
        ],
      );
    }
    final next = nextPrayer(day, tomorrow, now);
    final bearing = qiblaBearing(loc.lat, loc.lon);
    return ScreenBody(
      children: [
        const MoreTitle('Prayer times'),
        Text(
          '${loc.place} · ${ref.watch(prayerMethodProvider).label} · Asr ${s.madhab == AsrMadhab.hanafi ? 'Hanafi' : 'standard'}',
          style: meta(size: 13),
        ),
        Text(
          '${hijriLabel(parseDayKey(today))} · calculated (Umm al-Qura); '
          'local moon sighting can differ by a day',
          style: meta(size: 13),
        ),
        NCard(
          gap: 0,
          children: [
            for (final p in PrayerName.values)
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: next.name == p && isSameDay(next.at, day[p])
                      ? AppColors.sage200
                      : null,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        prayerLabels[p]!,
                        style: TextStyle(
                          fontSize: 16,
                          color: p == PrayerName.sunrise
                              ? AppColors.neutral700
                              : AppColors.text,
                        ),
                      ),
                    ),
                    Text(_t(day[p]), style: heading(18)),
                  ],
                ),
              ),
          ],
        ),
        NCard(
          children: [
            const Kicker('Qibla'),
            Text(
              '${bearing.toStringAsFixed(0)}° from true North',
              style: heading(22),
            ),
            Center(
              child: Semantics(
                label: 'Qibla arrow at ${bearing.round()} degrees from North',
                child: SizedBox.square(
                  dimension: 180,
                  child: CustomPaint(painter: _CompassPainter(bearing)),
                ),
              ),
            ),
            Text(
              'Face North with your phone, then turn to the arrow. '
              'This is a fixed bearing; it does not use the compass sensor.',
              style: meta(),
            ),
          ],
        ),
        Text(
          'Times are calculated on this phone and shown in its time zone. '
          'Check with your local mosque, especially for Fajr and Isha.',
          style: meta(),
        ),
      ],
    );
  }
}

class _CompassPainter extends CustomPainter {
  _CompassPainter(this.bearing);
  final double bearing;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2 - 14;
    canvas.drawCircle(c, r, Paint()..color = AppColors.neutral100);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = AppColors.divider
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    for (final (label, deg) in [('N', 0), ('E', 90), ('S', 180), ('W', 270)]) {
      final a = (deg - 90) * math.pi / 180;
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: label == 'N' ? AppColors.accent700 : AppColors.neutral700,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final p = c + Offset(math.cos(a), math.sin(a)) * (r + 8);
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }
    final a = (bearing - 90) * math.pi / 180;
    final tip = c + Offset(math.cos(a), math.sin(a)) * (r - 10);
    canvas.drawLine(
      c,
      tip,
      Paint()
        ..color = AppColors.sage600
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(tip, 7, Paint()..color = AppColors.accent700);
    canvas.drawCircle(c, 5, Paint()..color = AppColors.sage900);
  }

  @override
  bool shouldRepaint(_CompassPainter old) => old.bearing != bearing;
}
