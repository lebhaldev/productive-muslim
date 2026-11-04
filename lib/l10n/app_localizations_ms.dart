// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get tabToday => 'Hari ini';

  @override
  String get tabHabits => 'Tabiat';

  @override
  String get tabCalendar => 'Kalender';

  @override
  String get tabJournal => 'Jurnal';

  @override
  String get tabMore => 'Lagi';

  @override
  String get greetingMorning => 'Selamat pagi';

  @override
  String get greetingAfternoon => 'Selamat petang';

  @override
  String get greetingEvening => 'Selamat malam';

  @override
  String get sectionHabits => 'Tabiat';

  @override
  String get sectionMood => 'Apa perasaan anda?';

  @override
  String get allDoneToday => 'Semua selesai hari ini';

  @override
  String get excusedToday => 'Uzur hari ini';

  @override
  String get countTodayAgain => 'Kira hari ini semula';

  @override
  String nOfMToday(int done, int total) {
    return '$done daripada $total hari ini';
  }

  @override
  String get addFirstHabit => 'Tambah tabiat pertama anda';

  @override
  String get language => 'Bahasa';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية (pratonton)';

  @override
  String get undo => 'Buat asal';

  @override
  String get excusedNote =>
      'Hari ini tidak dikira untuk tabiat atau solat. Anda masih boleh menanda.';
}
