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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logged = ref.watch(prayerLogsProvider).value?[day] ?? const {};
    final start = times[PrayerName.fajr], end = times[PrayerName.isha];
    final span = end.difference(start).inSeconds.clamp(1, 1 << 31);
    double at(DateTime t) =>
        (t.difference(start).inSeconds / span).clamp(0.0, 1.0);

    return SizedBox(
      height: 96,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth - _dot, h = 96 - _dot - 16;
          Offset point(double f) => Offset(
            _dot / 2 + f * w,
            _dot / 2 + h - math.sin(math.pi * f) * h,
          );
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: ExcludeSemantics(
                  child: CustomPaint(
                    painter: _ArcPainter(
                      point: point,
                      marks: [
                        at(times[PrayerName.sunrise]),
                        at(times[PrayerName.maghrib]),
                      ],
                      color: AppColors.divider,
                      mark: AppColors.accent700,
                    ),
                  ),
                ),
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
                      width: isNext ? 22 : 16,
                      height: isNext ? 22 : 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done ? AppColors.sage600 : AppColors.surface,
                        border: Border.all(
                          color: isNext
                              ? AppColors.accent700
                              : done
                              ? AppColors.sage600
                              : AppColors.neutral700,
                          width: isNext ? 3 : 1.5,
                        ),
                      ),
                      child: done
                          ? Icon(Icons.check, size: 11, color: AppColors.bg)
                          : null,
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
    required this.color,
    required this.mark,
  });
  final Offset Function(double) point;
  final List<double> marks;
  final Color color;
  final Color mark;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(point(0).dx, point(0).dy);
    for (var i = 1; i <= 60; i++) {
      final o = point(i / 60);
      path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    // Sunrise and sunset: small terracotta ticks on the line.
    for (final f in marks) {
      final o = point(f);
      canvas.drawCircle(o, 3, Paint()..color = mark);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.marks.toString() != marks.toString() ||
      old.color != color ||
      old.mark != mark;
}
