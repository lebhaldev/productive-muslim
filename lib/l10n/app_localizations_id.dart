// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get tabToday => 'Hari ini';

  @override
  String get tabHabits => 'Kebiasaan';

  @override
  String get tabCalendar => 'Kalender';

  @override
  String get tabJournal => 'Jurnal';

  @override
  String get tabMore => 'Lainnya';

  @override
  String get greetingMorning => 'Selamat pagi';

  @override
  String get greetingAfternoon => 'Selamat siang';

  @override
  String get greetingEvening => 'Selamat malam';

  @override
  String get sectionHabits => 'Kebiasaan';

  @override
  String get sectionMood => 'Bagaimana perasaan Anda?';

  @override
  String get allDoneToday => 'Semua selesai hari ini';

  @override
  String get excusedToday => 'Berhalangan hari ini';

  @override
  String get countTodayAgain => 'Hitung hari ini lagi';

  @override
  String nOfMToday(int done, int total) {
    return '$done dari $total hari ini';
  }

  @override
  String get addFirstHabit => 'Tambahkan kebiasaan pertama Anda';

  @override
  String get language => 'Bahasa';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية (pratinjau)';

  @override
  String get undo => 'Urungkan';

  @override
  String get excusedNote =>
      'Hari ini tidak dihitung untuk kebiasaan atau salat. Anda tetap bisa mencentang.';
}
