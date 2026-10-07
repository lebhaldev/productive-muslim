/// Stable index for the day's content (FR-2): same all day, changes at
/// local midnight. FNV-1a over the day key and a salt per content kind.
int dailyIndex(String dayKey, String kind, int length) {
  var h = 0x811c9dc5;
  for (final c in '$kind|$dayKey'.codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xffffffff;
  }
  return h % length;
}

/// The day's item after the user asked for [offset] new ones ("Show
/// another"); wraps around the pool.
int contentIndex(String dayKey, String kind, int length, int offset) =>
    (dailyIndex(dayKey, kind, length) + offset) % length;
