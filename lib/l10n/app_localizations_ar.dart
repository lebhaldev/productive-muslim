// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get tabToday => 'اليوم';

  @override
  String get tabHabits => 'العادات';

  @override
  String get tabCalendar => 'التقويم';

  @override
  String get tabJournal => 'اليوميات';

  @override
  String get tabMore => 'المزيد';

  @override
  String get greetingMorning => 'صباح الخير';

  @override
  String get greetingAfternoon => 'مساء الخير';

  @override
  String get greetingEvening => 'مساء الخير';

  @override
  String get sectionHabits => 'العادات';

  @override
  String get sectionMood => 'كيف تشعر؟';

  @override
  String get allDoneToday => 'أنجزت كل شيء اليوم';

  @override
  String get excusedToday => 'معذور اليوم';

  @override
  String get countTodayAgain => 'احتسب اليوم مجددًا';

  @override
  String nOfMToday(int done, int total) {
    return '$done من $total اليوم';
  }

  @override
  String get addFirstHabit => 'أضف أول عادة';

  @override
  String get language => 'اللغة';

  @override
  String get languageSystem => 'لغة النظام';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية (تجريبي)';
}
