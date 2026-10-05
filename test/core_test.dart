import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/core/content_seed.dart';
import 'package:nurday/core/day_key.dart';
import 'package:nurday/core/streak.dart';

void main() {
  group('day keys', () {
    test('use the local calendar date, late evening stays on the same day', () {
      expect(dayKey(DateTime(2026, 10, 5, 23, 59)), '2026-10-05');
      expect(dayKey(DateTime(2026, 10, 6, 0, 1)), '2026-10-06');
    });

    test('shift across month, year and DST boundaries', () {
      expect(shiftDay('2026-10-01', -1), '2026-09-30');
      expect(shiftDay('2026-12-31', 1), '2027-01-01');
      expect(shiftDay('2026-03-29', -1), '2026-03-28');
      expect(shiftDay('2026-10-25', 1), '2026-10-26');
      expect(shiftDay('2024-02-28', 1), '2024-02-29');
    });
  });

  group('streaks', () {
    const today = '2026-10-05';
    test('count back from today when done today', () {
      expect(streak({'2026-10-05', '2026-10-04', '2026-10-03'}, today), 3);
    });
    test('count back from yesterday when today is not done yet', () {
      expect(streak({'2026-10-04', '2026-10-03'}, today), 2);
    });
    test('break on a missed day', () {
      expect(streak({'2026-10-05', '2026-10-03'}, today), 1);
      expect(streak({'2026-10-03'}, today), 0);
    });
    test('labels match the design', () {
      expect(streakLabel(0), '');
      expect(streakLabel(1), '1 day');
      expect(streakLabel(3), '3 days');
      expect(streakTag(0), 'Start today');
      expect(streakTag(3), '3-day streak');
    });
  });

  test('daily content index is stable for a day and varies across days', () {
    expect(
      dailyIndex('2026-10-05', 'ayah', 24),
      dailyIndex('2026-10-05', 'ayah', 24),
    );
    final seen = {
      for (var d = 1; d <= 28; d++)
        dailyIndex('2026-02-${d.toString().padLeft(2, '0')}', 'ayah', 24),
    };
    expect(seen.length, greaterThan(10));
  });
}
