import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/data/prayer/prayer.dart';
import 'package:nurday/data/reminders.dart';

void main() {
  // London, 5 Oct 2026, Muslim World League, standard Asr (UTC instants).
  final london = prayerDay(
    lat: 51.5074,
    lon: -0.1278,
    date: DateTime(2026, 10, 5),
  );

  test('times are in order and match the adhan reference for London', () {
    final utc = {for (final p in PrayerName.values) p: london[p].toUtc()};
    expect(utc[PrayerName.fajr], DateTime.utc(2026, 10, 5, 4, 16));
    expect(utc[PrayerName.sunrise], DateTime.utc(2026, 10, 5, 6, 8));
    expect(utc[PrayerName.dhuhr], DateTime.utc(2026, 10, 5, 11, 50));
    expect(utc[PrayerName.asr], DateTime.utc(2026, 10, 5, 14, 48));
    expect(utc[PrayerName.maghrib], DateTime.utc(2026, 10, 5, 17, 29));
    expect(utc[PrayerName.isha], DateTime.utc(2026, 10, 5, 19, 14));
  });

  test('Hanafi Asr is later than standard Asr', () {
    final hanafi = prayerDay(
      lat: 51.5074,
      lon: -0.1278,
      date: DateTime(2026, 10, 5),
      madhab: AsrMadhab.hanafi,
    );
    expect(hanafi[PrayerName.asr].isAfter(london[PrayerName.asr]), isTrue);
  });

  test('next prayer skips sunrise and rolls to tomorrow after Isha', () {
    final tomorrow = prayerDay(
      lat: 51.5074,
      lon: -0.1278,
      date: DateTime(2026, 10, 6),
    );
    final afterSunrise = london[PrayerName.sunrise].add(
      const Duration(minutes: 1),
    );
    expect(nextPrayer(london, tomorrow, afterSunrise).name, PrayerName.dhuhr);
    final late = london[PrayerName.isha].add(const Duration(minutes: 1));
    final n = nextPrayer(london, tomorrow, late);
    expect(n.name, PrayerName.fajr);
    expect(n.at, tomorrow[PrayerName.fajr]);
  });

  test('countdown labels', () {
    expect(untilLabel(const Duration(minutes: 80)), 'in 1 h 20 min');
    expect(untilLabel(const Duration(minutes: 60)), 'in 1 h');
    expect(untilLabel(const Duration(seconds: 30)), 'in 1 min');
    expect(untilLabel(Duration.zero), 'now');
  });

  test('Qibla from London is about 119 degrees', () {
    expect(qiblaBearing(51.5074, -0.1278), closeTo(119, 1));
  });

  test('Hijri date (Umm al-Qura)', () {
    expect(hijriLabel(DateTime(2026, 10, 5)), "24 Rabi' Al-Thani 1448");
  });

  test('methods parse with a safe default', () {
    expect(PrayerMethod.parse('ummAlQura'), PrayerMethod.ummAlQura);
    expect(PrayerMethod.parse(null), PrayerMethod.mwl);
    expect(AsrMadhab.parse('hanafi'), AsrMadhab.hanafi);
    expect(AsrMadhab.parse('x'), AsrMadhab.standard);
  });

  test('prayer reminders are one-off with their own ids', () {
    final at = DateTime(2026, 10, 5, 18, 29);
    final plan = planReminders(
      dailyTime: null,
      habits: const [],
      prayers: [(name: 'Maghrib', at: at, place: 'London')],
    );
    expect(plan.single.id, prayerReminderBase);
    expect(plan.single.at, at);
    expect(plan.single.body, 'Maghrib at 18:29 · London');
  });
}
