import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/data/db/database.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 10, 5, 8);
  setUp(() => db = memoryDb());
  tearDown(() => db.close());

  test('one journal per day: saving again updates the same entry', () async {
    await db.saveJournal('2026-10-05', 'A', 'first', now);
    await db.saveJournal(
      '2026-10-05',
      'B',
      'second',
      now.add(const Duration(hours: 1)),
    );
    final all = await db.watchJournals().first;
    expect(all, hasLength(1));
    expect(all.single.title, 'B');
    expect(all.single.body, 'second');
    expect(all.single.createdAt, now);
  });

  test('an empty body is not saved as an entry', () async {
    await db.saveJournal('2026-10-05', 'Title only', '   ', now);
    expect(await db.watchJournals().first, isEmpty);
    await db.saveJournal('2026-10-05', '', 'text', now);
    await db.saveJournal('2026-10-05', '', '', now);
    expect(await db.watchJournals().first, isEmpty);
  });

  test('one mood per day, replaced on a new pick', () async {
    await db.setMood('2026-10-05', 1, now);
    await db.setMood('2026-10-05', 4, now);
    final moods = await db.watchMoods().first;
    expect(moods.single.value, 4);
  });

  test('habit completion toggles and deletes with the habit', () async {
    final id = await db.addHabit('Walk');
    await db.toggleCompletion(id, '2026-10-05');
    expect(await db.watchCompletions().first, hasLength(1));
    await db.toggleCompletion(id, '2026-10-05');
    expect(await db.watchCompletions().first, isEmpty);
    await db.toggleCompletion(id, '2026-10-04');
    await db.deleteHabit(id);
    expect(await db.watchCompletions().first, isEmpty);
  });

  test('move up swaps order with the habit above', () async {
    await db.addHabit('A');
    await db.addHabit('B');
    final c = await db.addHabit('C');
    await db.moveUp(c);
    final names = (await db.watchHabits().first).map((h) => h.name).toList();
    expect(names, ['A', 'C', 'B']);
  });
}
