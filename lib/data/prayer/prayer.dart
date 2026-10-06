import 'package:adhan/adhan.dart' as adhan;
import 'package:hijri/hijri_calendar.dart';

/// Calculation methods offered in Settings (FR-12), in display order.
enum PrayerMethod {
  mwl('Muslim World League', adhan.CalculationMethod.muslim_world_league),
  isna('North America (ISNA)', adhan.CalculationMethod.north_america),
  egyptian('Egyptian General Authority', adhan.CalculationMethod.egyptian),
  karachi(
    'University of Islamic Sciences, Karachi',
    adhan.CalculationMethod.karachi,
  ),
  ummAlQura('Umm al-Qura, Makkah', adhan.CalculationMethod.umm_al_qura),
  dubai('Dubai', adhan.CalculationMethod.dubai),
  qatar('Qatar', adhan.CalculationMethod.qatar),
  kuwait('Kuwait', adhan.CalculationMethod.kuwait),
  moonsighting(
    'Moonsighting Committee',
    adhan.CalculationMethod.moon_sighting_committee,
  ),
  singapore('Singapore', adhan.CalculationMethod.singapore),
  turkey('Diyanet, Turkey', adhan.CalculationMethod.turkey),
  tehran('Tehran', adhan.CalculationMethod.tehran);

  const PrayerMethod(this.label, this.method);
  final String label;
  final adhan.CalculationMethod method;

  static PrayerMethod parse(String? s) =>
      values.firstWhere((m) => m.name == s, orElse: () => mwl);

  /// The method commonly used in a country; Muslim World League otherwise.
  static PrayerMethod forCountry(String? code) => switch (code?.toUpperCase()) {
    'US' || 'CA' => isna,
    'PK' || 'IN' || 'BD' || 'AF' => karachi,
    'SA' || 'YE' => ummAlQura,
    'EG' || 'SD' || 'LY' || 'SY' || 'LB' || 'IQ' || 'JO' || 'PS' => egyptian,
    'AE' => dubai,
    'QA' => qatar,
    'KW' => kuwait,
    'TR' => turkey,
    'IR' => tehran,
    'SG' || 'MY' || 'ID' || 'BN' => singapore,
    _ => mwl,
  };
}

enum AsrMadhab {
  standard("Standard (Shafi'i, Maliki, Hanbali)", adhan.Madhab.shafi),
  hanafi('Hanafi', adhan.Madhab.hanafi);

  const AsrMadhab(this.label, this.madhab);
  final String label;
  final adhan.Madhab madhab;

  static AsrMadhab parse(String? s) => s == 'hanafi' ? hanafi : standard;
}

/// How Fajr and Isha are bounded where twilight never ends (summer, far north).
enum HighLatitude {
  middle('Middle of the night', adhan.HighLatitudeRule.middle_of_the_night),
  seventh('Seventh of the night', adhan.HighLatitudeRule.seventh_of_the_night),
  angle('Twilight angle', adhan.HighLatitudeRule.twilight_angle);

  const HighLatitude(this.label, this.rule);
  final String label;
  final adhan.HighLatitudeRule rule;

  static HighLatitude parse(String? s) =>
      values.firstWhere((h) => h.name == s, orElse: () => middle);
}

enum PrayerName { fajr, sunrise, dhuhr, asr, maghrib, isha }

const prayerLabels = {
  PrayerName.fajr: 'Fajr',
  PrayerName.sunrise: 'Sunrise',
  PrayerName.dhuhr: 'Dhuhr',
  PrayerName.asr: 'Asr',
  PrayerName.maghrib: 'Maghrib',
  PrayerName.isha: 'Isha',
};

/// The five daily prayers; sunrise is shown but is not a prayer.
const fivePrayers = [
  PrayerName.fajr,
  PrayerName.dhuhr,
  PrayerName.asr,
  PrayerName.maghrib,
  PrayerName.isha,
];

/// One day's times as local DateTimes.
class PrayerDay {
  const PrayerDay(this.times);
  final Map<PrayerName, DateTime> times;

  DateTime operator [](PrayerName p) => times[p]!;
}

/// Computes times on the device; no network (FR-12).
PrayerDay prayerDay({
  required double lat,
  required double lon,
  required DateTime date,
  PrayerMethod method = PrayerMethod.mwl,
  AsrMadhab madhab = AsrMadhab.standard,
  HighLatitude highLatitude = HighLatitude.middle,
}) {
  final params = method.method.getParameters()
    ..madhab = madhab.madhab
    ..highLatitudeRule = highLatitude.rule;
  final t = adhan.PrayerTimes.utc(
    adhan.Coordinates(lat, lon),
    adhan.DateComponents(date.year, date.month, date.day),
    params,
  );
  return PrayerDay({
    PrayerName.fajr: t.fajr.toLocal(),
    PrayerName.sunrise: t.sunrise.toLocal(),
    PrayerName.dhuhr: t.dhuhr.toLocal(),
    PrayerName.asr: t.asr.toLocal(),
    PrayerName.maghrib: t.maghrib.toLocal(),
    PrayerName.isha: t.isha.toLocal(),
  });
}

/// The next of the five prayers after [now]; after Isha it is tomorrow's Fajr.
({PrayerName name, DateTime at}) nextPrayer(
  PrayerDay today,
  PrayerDay tomorrow,
  DateTime now,
) {
  for (final p in fivePrayers) {
    if (today[p].isAfter(now)) return (name: p, at: today[p]);
  }
  return (name: PrayerName.fajr, at: tomorrow[PrayerName.fajr]);
}

/// `in 1 h 20 min`, `in 5 min`, `now`.
String untilLabel(Duration d) {
  final m = (d.inSeconds / 60).ceil();
  if (m <= 0) return 'now';
  final h = m ~/ 60, r = m % 60;
  if (h == 0) return 'in $r min';
  return r == 0 ? 'in $h h' : 'in $h h $r min';
}

/// Great-circle bearing to the Kaaba, degrees clockwise from true North (FR-14).
double qiblaBearing(double lat, double lon) =>
    adhan.Qibla(adhan.Coordinates(lat, lon)).direction;

/// Umm al-Qura Hijri date, e.g. `23 Rabi' al-Thani 1448` (FR-13).
String hijriLabel(DateTime date) {
  final h = HijriCalendar.fromDate(DateTime(date.year, date.month, date.day));
  return '${h.hDay} ${h.getLongMonthName()} ${h.hYear}';
}
