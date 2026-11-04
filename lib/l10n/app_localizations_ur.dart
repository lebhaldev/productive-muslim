// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get tabToday => 'آج';

  @override
  String get tabHabits => 'عادتیں';

  @override
  String get tabCalendar => 'کیلنڈر';

  @override
  String get tabJournal => 'ڈائری';

  @override
  String get tabMore => 'مزید';

  @override
  String get greetingMorning => 'صبح بخیر';

  @override
  String get greetingAfternoon => 'سہ پہر بخیر';

  @override
  String get greetingEvening => 'شام بخیر';

  @override
  String get sectionHabits => 'عادتیں';

  @override
  String get sectionMood => 'آپ کیسا محسوس کر رہے ہیں؟';

  @override
  String get allDoneToday => 'آج سب مکمل';

  @override
  String get excusedToday => 'آج معذور';

  @override
  String get countTodayAgain => 'آج کو دوبارہ شمار کریں';

  @override
  String nOfMToday(int done, int total) {
    return 'آج $total میں سے $done';
  }

  @override
  String get addFirstHabit => 'اپنی پہلی عادت شامل کریں';

  @override
  String get language => 'زبان';

  @override
  String get languageSystem => 'سسٹم';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية (پیش منظر)';

  @override
  String get undo => 'واپس کریں';

  @override
  String get excusedNote =>
      'آج عادتوں یا نمازوں میں شمار نہیں ہوگا۔ آپ پھر بھی نشان لگا سکتے ہیں۔';
}
