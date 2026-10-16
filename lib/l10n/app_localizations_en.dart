// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tabToday => 'Today';

  @override
  String get tabHabits => 'Habits';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabJournal => 'Journal';

  @override
  String get tabMore => 'More';

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get sectionHabits => 'Habits';

  @override
  String get sectionMood => 'How do you feel?';

  @override
  String get allDoneToday => 'All done today';

  @override
  String get excusedToday => 'Excused today';

  @override
  String get countTodayAgain => 'Count today again';

  @override
  String nOfMToday(int done, int total) {
    return '$done of $total today';
  }

  @override
  String get addFirstHabit => 'Add your first habit';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية (preview)';
}
