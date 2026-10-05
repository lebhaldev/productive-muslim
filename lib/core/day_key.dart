/// A local calendar date, stored as `YYYY-MM-DD`.
///
/// Every record in Nurday belongs to a local day, never a UTC instant, so an
/// entry written at 23:30 stays on that evening's date (FR-1).
String dayKey(DateTime local) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)}';
}

/// Parses a day key back to a local DateTime at noon, which avoids DST edges.
DateTime parseDayKey(String key) {
  final p = key.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2], 12);
}

/// The day key [days] days after [key] (negative goes back).
String shiftDay(String key, int days) {
  final d = parseDayKey(key);
  return dayKey(DateTime(d.year, d.month, d.day + days, 12));
}
