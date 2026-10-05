import 'day_key.dart';

/// Consecutive days with a hit, ending today, or ending yesterday when today
/// has no hit yet (FR-5, FR-7).
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

/// `1 day`, `3 days`, or empty at zero (Today habit rows).
String streakLabel(int n) => n == 0 ? '' : '$n day${n == 1 ? '' : 's'}';

/// `3-day streak` or `Start today` (Habits cards).
String streakTag(int n) => n == 0 ? 'Start today' : '$n-day streak';
