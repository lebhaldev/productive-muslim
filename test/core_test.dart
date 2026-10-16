import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/core/content_seed.dart';
import 'package:nurday/core/day_key.dart';
import 'package:nurday/core/streak.dart';
import 'package:nurday/features/today/mood_week.dart';

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

  test('the mood week runs Monday to Sunday', () {
    expect(weekOf('2026-10-08'), [
      '2026-10-05',
      '2026-10-06',
      '2026-10-07',
      '2026-10-08',
      '2026-10-09',
      '2026-10-10',
      '2026-10-11',
    ]);
    expect(weekOf('2026-11-01').first, '2026-10-26');
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
    test('consistency counts the last 7 days without excused days', () {
      final c = consistency(
        {'2026-10-05', '2026-10-03', '2026-09-28'},
        today,
        {'2026-10-04'},
      );
      expect(c, (done: 2, of: 6));
      expect(consistency({}, today), (done: 0, of: 7));
    });
    test('labels match the design', () {
      expect(consistencyTag((done: 0, of: 7)), 'Start today');
      expect(consistencyTag((done: 3, of: 7)), '3 of the last 7 days');
      expect(consistencyTag((done: 2, of: 6)), '2 of the last 6 days');
      expect(consistencyLabel((done: 0, of: 7)), '');
      expect(consistencyLabel((done: 1, of: 7)), '1 of 7 days');
      expect(consistencyLabel((done: 1, of: 1)), '1 of 1 day');
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
