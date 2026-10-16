import 'day_key.dart';

/// Consecutive days with a hit, ending today, or ending yesterday when today
/// has no hit yet (FR-5, FR-7). Used for the journal on Reflect; habits use
/// [consistency] instead (FR-17).
int streak(Set<String> days, String today) {
  var d = today;
  if (!days.contains(d)) d = shiftDay(d, -1);
  var n = 0;
  while (days.contains(d)) {
    n++;
    d = shiftDay(d, -1);
  }
  return n;
}

typedef Consistency = ({int done, int of});

/// Done days among the last 7 day keys ending today, with excused days
/// removed from both counts (FR-17, FR-18).
Consistency consistency(
  Set<String> days,
  String today, [
  Set<String> excused = const {},
]) {
  var done = 0, of = 0;
  for (var back = 0; back < 7; back++) {
    final d = shiftDay(today, -back);
    if (excused.contains(d)) continue;
    of++;
    if (days.contains(d)) done++;
  }
  return (done: done, of: of);
}

String _days(int n) => n == 1 ? '1 day' : '$n days';

/// `3 of the last 7 days`, or `Start today` with nothing done (Habits cards).
String consistencyTag(Consistency c) {
  if (c.done == 0) return 'Start today';
  return c.of == 7
      ? '${c.done} of the last 7 days'
      : '${c.done} of the last ${_days(c.of)}';
}

/// `3 of 7 days`, or empty with nothing done (Today habit rows).
String consistencyLabel(Consistency c) =>
    c.done == 0 ? '' : '${c.done} of ${_days(c.of)}';
