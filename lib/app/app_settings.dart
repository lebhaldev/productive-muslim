import 'package:flutter/material.dart' show ThemeMode;

import '../data/content/quran_client.dart';
import '../data/prayer/prayer.dart';
import 'theme.dart';

/// Typed view over the key/value settings table.
class AppSettings {
  const AppSettings(this.raw);
  final Map<String, String> raw;

  bool get showFaith => raw['faith'] != 'false';
  bool get fahrenheit => raw['unit'] == 'F';
  bool get journalLock => raw['journalLock'] == 'true';
  bool get driveBackup => raw['driveBackup'] == 'true';
  DateTime? get driveLastBackup =>
      DateTime.tryParse(raw['driveLastBackup'] ?? '');
  Translation get translation => Translation.parse(raw['translation']);
  String get city => raw['city'] ?? '';
  double? get lat => double.tryParse(raw['lat'] ?? '');
  double? get lon => double.tryParse(raw['lon'] ?? '');

  /// Name shown for a picked city or "Use my location" (reverse geocoded).
  String? get placeName =>
      (raw['placeName'] ?? '').isEmpty ? null : raw['placeName'];
  String? get countryCode =>
      (raw['countryCode'] ?? '').isEmpty ? null : raw['countryCode'];
  String get dailyReminder => raw['dailyReminder'] ?? '07:30';
  // Off until the user turns it on, so first launch shows no prompt.
  bool get dailyReminderOn => raw['dailyReminderOn'] == 'true';

  ColorTheme get colorTheme => ColorTheme.values.firstWhere(
    (t) => t.name == raw['colorTheme'],
    orElse: () => ColorTheme.sage,
  );

  ThemeMode get themeMode => switch (raw['themeMode']) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  /// Null until the user picks one; then the country default applies.
  PrayerMethod? get chosenPrayerMethod => raw['prayerMethod'] == null
      ? null
      : PrayerMethod.parse(raw['prayerMethod']);
  AsrMadhab get madhab => AsrMadhab.parse(raw['madhab']);
  HighLatitude get highLatitude => HighLatitude.parse(raw['highLatitude']);
  // Off by default, like the daily reminder.
  bool get prayerAlerts => raw['prayerAlerts'] == 'true';

  /// Content language: Arabic with the English translation, or Arabic only.
  bool get arabicOnly => raw['contentLanguage'] == 'ar';
}
