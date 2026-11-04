// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get tabToday => 'Aujourd\'hui';

  @override
  String get tabHabits => 'Habitudes';

  @override
  String get tabCalendar => 'Calendrier';

  @override
  String get tabJournal => 'Journal';

  @override
  String get tabMore => 'Plus';

  @override
  String get greetingMorning => 'Bonjour';

  @override
  String get greetingAfternoon => 'Bon après-midi';

  @override
  String get greetingEvening => 'Bonsoir';

  @override
  String get sectionHabits => 'Habitudes';

  @override
  String get sectionMood => 'Comment vous sentez-vous ?';

  @override
  String get allDoneToday => 'Tout est fait aujourd\'hui';

  @override
  String get excusedToday => 'Excusé aujourd\'hui';

  @override
  String get countTodayAgain => 'Compter aujourd\'hui à nouveau';

  @override
  String nOfMToday(int done, int total) {
    return '$done sur $total aujourd\'hui';
  }

  @override
  String get addFirstHabit => 'Ajoutez votre première habitude';

  @override
  String get language => 'Langue';

  @override
  String get languageSystem => 'Système';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية (aperçu)';

  @override
  String get undo => 'Annuler';

  @override
  String get excusedNote =>
      'Aujourd\'hui ne comptera pas pour les habitudes ni les prières. Vous pouvez quand même cocher.';
}
