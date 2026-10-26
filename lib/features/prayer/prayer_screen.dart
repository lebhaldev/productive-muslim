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
import 'prayer_arc.dart';

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
    final nextToday = isSameDay(next.at, day[next.name]) ? next.name : null;
    final until = untilLabel(next.at.difference(now));
    return NCard(
      onTap: () => context.go('/more/prayer'),
      children: [
        Row(
          children: [
            const Expanded(child: Kicker('Prayer today')),
            Flexible(
              child: Text(
                ref.watch(prayerLocationProvider)?.place ?? '',
                overflow: TextOverflow.ellipsis,
                style: meta(),
              ),
            ),
          ],
        ),
        PrayerArc(day: today, times: day, now: now, next: nextToday),
        Row(
          children: [
            Expanded(
              child: Semantics(
                container: true,
                label: '$label at ${_t(next.at)}, $until',
                child: ExcludeSemantics(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: label,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: ' · ${_t(next.at)} · $until'),
                      ],
                    ),
                    style: TextStyle(fontSize: 16, color: AppColors.text),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              key: const Key('qibla-button'),
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                side: BorderSide(color: AppColors.neutral400),
              ),
              onPressed: () => context.go('/more/prayer'),
              child: const Text('Qibla'),
            ),
          ],
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
    final nextToday = isSameDay(next.at, day[next.name]) ? next.name : null;
    final logged = ref.watch(prayerLogsProvider).value?[today] ?? const {};
    final bearing = qiblaBearing(loc.lat, loc.lon);
    return ScreenBody(
      children: [
        const MoreTitle('Prayer times'),
        Text(
          'Asr ${s.madhab == AsrMadhab.hanafi ? 'Hanafi' : 'standard'} · change in Settings',
          style: meta(size: 13),
        ),
        Text(
          '${hijriLabel(parseDayKey(today), offset: s.hijriOffset)} · '
          'calculated (Umm al-Qura${s.hijriOffset == 0 ? '' : ', ${s.hijriOffset > 0 ? '+' : ''}${s.hijriOffset} days'}); '
          'local moon sighting can differ by a day',
          style: meta(size: 13),
        ),
        NCard(
          children: [
            PrayerArc(day: today, times: day, now: now, next: nextToday),
            Text(
              'Tap a prayer that has started to log it. Logs stay on this phone.',
              style: meta(),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final p in PrayerName.values) ...[
              _PrayerRow(
                key: Key('prayer-row-${p.name}'),
                p: p,
                at: day[p],
                isNext: p == nextToday,
                done: logged.contains(p.name),
                until: untilLabel(next.at.difference(now)),
                onTap: p == PrayerName.sunrise || day[p].isAfter(now)
                    ? null
                    : () => togglePrayerLog(context, ref, today, p),
              ),
              const SizedBox(height: 8),
            ],
            Text(
              'Calculated on this phone · '
              '${ref.watch(prayerMethodProvider).label} · ${loc.place}',
              style: meta(size: 12),
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

/// One row of today's times: `Done`, `Next · in 1 h 12 min`, or nothing.
/// Never a "missed" state (FR-16).
class _PrayerRow extends StatelessWidget {
  const _PrayerRow({
    super.key,
    required this.p,
    required this.at,
    required this.isNext,
    required this.done,
    required this.until,
    this.onTap,
  });
  final PrayerName p;
  final DateTime at;
  final bool isNext;
  final bool done;
  final String until;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final status = done
        ? 'Done'
        : isNext
        ? 'Next · $until'
        : null;
    final sunrise = p == PrayerName.sunrise;
    return Semantics(
      button: onTap != null,
      checked: onTap != null ? done : null,
      label: '${prayerLabels[p]} ${_t(at)}${status == null ? '' : ', $status'}',
      excludeSemantics: true,
      child: Material(
        color: sunrise
            ? Colors.transparent
            : isNext
            ? AppColors.sage200
            : AppColors.neutral200,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 26,
                  child: sunrise
                      ? null
                      : Align(
                          alignment: AlignmentDirectional.centerStart,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done ? AppColors.sage600 : null,
                              border: Border.all(
                                color: done || isNext
                                    ? AppColors.sage600
                                    : AppColors.neutral700,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                ),
                Expanded(
                  child: Text(
                    prayerLabels[p]!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isNext ? FontWeight.w700 : null,
                      color: AppColors.text,
                    ),
                  ),
                ),
                if (status != null)
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 16),
                      child: Text(
                        status,
                        style: meta(size: 12, color: AppColors.neutral800),
                      ),
                    ),
                  ),
                Text(
                  _t(at),
                  style: TextStyle(fontSize: 16, color: AppColors.text),
                ),
              ],
            ),
          ),
        ),
      ),
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
