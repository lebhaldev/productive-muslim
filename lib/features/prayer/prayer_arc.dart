import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/prayer/prayer.dart';
import '../../widgets/motion.dart';

/// Logs or unlogs [p] on [day] and says so with an Undo (FR-16).
Future<void> togglePrayerLog(
  BuildContext context,
  WidgetRef ref,
  String day,
  PrayerName p,
) async {
  final db = ref.read(databaseProvider);
  final now = ref.read(clockProvider).now();
  final wasLogged =
      ref.read(prayerLogsProvider).value?[day]?.contains(p.name) ?? false;
  await db.togglePrayer(day, p.name, now);
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text('${prayerLabels[p]} ${wasLogged ? 'unmarked' : 'logged'}'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () => db.togglePrayer(day, p.name, now),
      ),
    ),
  );
}

/// The day from Fajr to Isha as a gentle arc: logged prayers filled sage,
/// the next one ringed, sunrise and sunset marked. Each prayer that has
/// started can be tapped to log it.
class PrayerArc extends ConsumerWidget {
  const PrayerArc({
    super.key,
    required this.day,
    required this.times,
    required this.now,
    this.next,
  });

  final String day;
  final PrayerDay times;
  final DateTime now;

  /// Today's next prayer, ringed; null when it is tomorrow's Fajr.
  final PrayerName? next;

  static const _dot = 30.0;
  static const _height = 124.0;
  static const _ticks = 18.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logged = ref.watch(prayerLogsProvider).value?[day] ?? const {};
    final start = times[PrayerName.fajr], end = times[PrayerName.isha];
    final span = end.difference(start).inSeconds.clamp(1, 1 << 31);
    double at(DateTime t) =>
        (t.difference(start).inSeconds / span).clamp(0.0, 1.0);

    final sunrise = times[PrayerName.sunrise],
        sunset = times[PrayerName.maghrib];
    final nowF = now.isBefore(start) ? 0.0 : at(now);
    final showNow = isSameDate(now, start) && !now.isBefore(start);

    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth - _dot, h = _height - _dot - 16 - _ticks;
          Offset point(double f) => Offset(
            _dot / 2 + f * w,
            _dot / 2 + h - math.sin(math.pi * f) * h,
          );
          Widget tickLabel(String text, double f) {
            final x = point(f).dx;
            return Positioned(
              left: (x - 40).clamp(0.0, math.max(0.0, c.maxWidth - 80)),
              width: 80,
              bottom: 0,
              child: ExcludeSemantics(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  style: meta(size: 10),
                ),
              ),
            );
          }

          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ExcludeSemantics(
                  child: CustomPaint(
                    painter: _ArcPainter(
                      point: point,
                      marks: [at(sunrise), at(sunset)],
                      floor: _height - 14,
                      progress: nowF,
                      showNow: showNow,
                      color: AppColors.divider,
                      done: AppColors.sage400,
                      tick: AppColors.neutral500,
                      nowColor: AppColors.accent700,
                    ),
                  ),
                ),
              ),
              tickLabel(
                'sunrise ${DateFormat('HH:mm').format(sunrise)}',
                at(sunrise),
              ),
              tickLabel(
                'sunset ${DateFormat('HH:mm').format(sunset)}',
                at(sunset),
              ),
              for (final p in fivePrayers)
                _point(context, ref, p, point(at(times[p])), logged),
            ],
          );
        },
      ),
    );
  }

  Widget _point(
    BuildContext context,
    WidgetRef ref,
    PrayerName p,
    Offset c,
    Set<String> logged,
  ) {
    final done = logged.contains(p.name);
    final started = !times[p].isAfter(now);
    final isNext = p == next;
    final time = DateFormat('HH:mm').format(times[p]);
    final label = prayerLabels[p]!;
    return Positioned(
      left: c.dx - _dot / 2,
      top: c.dy - _dot / 2,
      child: Semantics(
        button: started,
        checked: started ? done : null,
        label: '$label $time${started ? '' : ', not yet'}',
        hint: started ? (done ? 'Tap to unmark' : 'Tap to log') : null,
        excludeSemantics: true,
        child: GestureDetector(
          key: Key('arc-${p.name}'),
          behavior: HitTestBehavior.opaque,
          onTap: started ? () => togglePrayerLog(context, ref, day, p) : null,
          child: SizedBox(
            width: _dot,
            height: _dot + 16,
            child: Column(
              children: [
                Container(
                  width: _dot,
                  height: _dot,
                  alignment: Alignment.center,
                  child: TickBurst(
                    on: done,
                    color: AppColors.sage600,
                    child: AnimatedContainer(
                      duration: motion(context, Motion.medium),
                      curve: Curves.easeOutBack,
                      width: isNext ? 20 : 18,
                      height: isNext ? 20 : 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? AppColors.sage600 : AppColors.surface,
                        border: Border.all(
                          color: done || isNext
                              ? AppColors.sage600
                              : AppColors.neutral700,
                          width: isNext ? 3.5 : 2,
                        ),
                      ),
                    ),
                  ),
                ),
                // The name may be wider than the dot; let it spill sideways.
                SizedBox(
                  height: 16,
                  child: OverflowBox(
                    maxWidth: 72,
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      style: meta(size: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({
    required this.point,
    required this.marks,
    required this.floor,
    required this.progress,
    required this.showNow,
    required this.color,
    required this.done,
    required this.tick,
    required this.nowColor,
  });
  final Offset Function(double) point;
  final List<double> marks;
  final double floor, progress;
  final bool showNow;
  final Color color, done, tick, nowColor;

  Path _segment(double from, double to) {
    final path = Path()..moveTo(point(from).dx, point(from).dy);
    final steps = math.max(1, ((to - from) * 60).ceil());
    for (var i = 1; i <= steps; i++) {
      final o = point(from + (to - from) * i / steps);
      path.lineTo(o.dx, o.dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint stroke(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(_segment(0, 1), stroke(color));
    if (progress > 0) canvas.drawPath(_segment(0, progress), stroke(done));
    // Sunrise and sunset: small dashed ticks from the line down to a label.
    final dash = Paint()
      ..color = tick
      ..strokeWidth = 1.2;
    for (final f in marks) {
      final o = point(f);
      for (var y = o.dy + 6; y < floor - 2; y += 6) {
        canvas.drawLine(
          Offset(o.dx, y),
          Offset(o.dx, math.min(y + 3, floor)),
          dash,
        );
      }
    }
    if (showNow) {
      canvas.drawCircle(point(progress), 4.5, Paint()..color = nowColor);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.marks.toString() != marks.toString() ||
      old.progress != progress ||
      old.showNow != showNow ||
      old.color != color ||
      old.done != done;
}

bool isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
