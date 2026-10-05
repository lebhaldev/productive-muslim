import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/data/reminders.dart';

void main() {
  test('plan has the daily reminder plus one per active habit with a time', () {
    final plan = planReminders(
      dailyTime: '07:30',
      habits: [
        (id: 1, name: 'Read Quran 10 min', time: '06:00', archived: false),
        (id: 2, name: 'Walk', time: null, archived: false),
        (id: 3, name: 'Old habit', time: '21:00', archived: true),
      ],
    );
    expect(plan.map((r) => (r.id, r.time)).toList(), [
      (0, '07:30'),
      (1001, '06:00'),
    ]);
    expect(plan[1].body, 'Time for: Read Quran 10 min');
  });

  test('daily reminder off leaves only habit reminders', () {
    final plan = planReminders(
      dailyTime: null,
      habits: [(id: 1, name: 'Walk', time: '18:00', archived: false)],
    );
    expect(plan.single.id, 1001);
  });
}
