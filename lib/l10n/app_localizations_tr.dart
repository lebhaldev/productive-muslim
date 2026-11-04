// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get tabToday => 'Bugün';

  @override
  String get tabHabits => 'Alışkanlıklar';

  @override
  String get tabCalendar => 'Takvim';

  @override
  String get tabJournal => 'Günlük';

  @override
  String get tabMore => 'Daha Fazla';

  @override
  String get greetingMorning => 'Günaydın';

  @override
  String get greetingAfternoon => 'Tünaydın';

  @override
  String get greetingEvening => 'İyi akşamlar';

  @override
  String get sectionHabits => 'Alışkanlıklar';

  @override
  String get sectionMood => 'Nasıl hissediyorsunuz?';

  @override
  String get allDoneToday => 'Bugün hepsi tamam';

  @override
  String get excusedToday => 'Bugün mazeretli';

  @override
  String get countTodayAgain => 'Bugünü yeniden say';

  @override
  String nOfMToday(int done, int total) {
    return 'Bugün $total işin $done tanesi';
  }

  @override
  String get addFirstHabit => 'İlk alışkanlığınızı ekleyin';

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية (önizleme)';

  @override
  String get undo => 'Geri al';

  @override
  String get excusedNote =>
      'Bugün alışkanlıklar ve namazlar için sayılmaz. Yine de işaretleyebilirsiniz.';
}
