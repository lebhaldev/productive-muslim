import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/data/prayer/prayer.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Checks our wrapper against the adhan project's own reference tables
/// (test/fixtures/adhan, MIT). New York covers a full year, so both DST
/// switches; London is Moonsighting Committee + Hanafi at 51.5°N.
void main() {
  tzdata.initializeTimeZones();

  const methods = {
    'UmmAlQura': PrayerMethod.ummAlQura,
    'MoonsightingCommittee': PrayerMethod.moonsighting,
    'north_america': PrayerMethod.isna,
  };

  DateTime local(tz.Location loc, String date, String clock) {
    final d = date.split('-').map(int.parse).toList();
    final m = RegExp(r'(\d+):(\d+) (AM|PM)').firstMatch(clock)!;
    var h = int.parse(m[1]!) % 12;
    if (m[3] == 'PM') h += 12;
    return tz.TZDateTime(loc, d[0], d[1], d[2], h, int.parse(m[2]!)).toUtc();
  }

  for (final file in [
    'Makkah-UmmAlQura.json',
    'London-MoonsightingCommittee.json',
    'NewYork-NorthAmerica-Hanafi-Generated-Using-V1.json',
  ]) {
    test('matches adhan reference times: $file', () {
      final data = jsonDecode(
        File('test/fixtures/adhan/$file').readAsStringSync(),
      );
      final p = data['params'] as Map<String, dynamic>;
      final loc = tz.getLocation(p['timezone'] as String);
      final method = methods[p['method']]!;
      final madhab = AsrMadhab.parse(
        (p['madhab'] as String).toLowerCase() == 'hanafi' ? 'hanafi' : null,
      );
      var checked = 0;
      for (final t in data['times'] as List) {
        final date = (t['date'] as String).split('-').map(int.parse).toList();
        final day = prayerDay(
          lat: (p['latitude'] as num).toDouble(),
          lon: (p['longitude'] as num).toDouble(),
          date: DateTime(date[0], date[1], date[2]),
          method: method,
          madhab: madhab,
        );
        for (final (name, key) in [
          (PrayerName.fajr, 'fajr'),
          (PrayerName.sunrise, 'sunrise'),
          (PrayerName.dhuhr, 'dhuhr'),
          (PrayerName.asr, 'asr'),
          (PrayerName.maghrib, 'maghrib'),
          (PrayerName.isha, 'isha'),
        ]) {
          final want = local(loc, t['date'] as String, t[key] as String);
          final diff = day[name].toUtc().difference(want).inMinutes.abs();
          expect(diff, lessThanOrEqualTo(1), reason: '${t['date']} $key');
          checked++;
        }
      }
      expect(checked, greaterThan(60));
    });
  }

  test('high latitude: Tromsø in June still gets Fajr before sunrise', () {
    for (final rule in HighLatitude.values) {
      final day = prayerDay(
        lat: 69.65,
        lon: 18.96,
        date: DateTime(2026, 3, 20),
        highLatitude: rule,
      );
      expect(day[PrayerName.fajr].isBefore(day[PrayerName.sunrise]), isTrue);
      expect(day[PrayerName.isha].isAfter(day[PrayerName.maghrib]), isTrue);
    }
    // Oslo near the solstice: twilight never ends, the rule decides Isha.
    final middle = prayerDay(
      lat: 59.91,
      lon: 10.75,
      date: DateTime(2026, 6, 21),
    );
    final seventh = prayerDay(
      lat: 59.91,
      lon: 10.75,
      date: DateTime(2026, 6, 21),
      highLatitude: HighLatitude.seventh,
    );
    expect(middle[PrayerName.isha], isNot(seventh[PrayerName.isha]));
    expect(
      middle[PrayerName.fajr].isBefore(middle[PrayerName.sunrise]),
      isTrue,
    );
  });
}
