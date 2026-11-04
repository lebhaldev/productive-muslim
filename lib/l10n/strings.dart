import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/widgets.dart';

/// Interface languages. Content (ayah, hadith, tafsir, quotes) is never
/// translated by the app; only the interface is.
enum AppLanguage {
  system('System', null),
  en('English', 'en'),
  ar('العربية', 'ar'),
  fr('Français', 'fr'),
  id('Bahasa Indonesia', 'id'),
  ms('Bahasa Melayu', 'ms'),
  tr('Türkçe', 'tr'),
  ur('اردو', 'ur');

  const AppLanguage(this.nativeName, this.code);

  /// The language's own name, shown untranslated in the picker.
  final String nativeName;
  final String? code;

  static AppLanguage parse(String? s) =>
      values.firstWhere((l) => l.name == s, orElse: () => system);
}

/// Languages a native speaker has reviewed. Until then a language shows only
/// when picked in Settings, never because the phone uses it (FR-21).
const reviewedLanguages = <String>{'en'};

/// Interface strings keyed by their English text, one map per language,
/// loaded from `assets/l10n/<code>.json`. A missing entry falls back to the
/// English key, so untranslated text still shows.
abstract final class AppStrings {
  static Map<String, Map<String, String>> _all = {};
  static Map<String, String> current = const {};
  static String code = 'en';

  static Future<void> load() async {
    final all = <String, Map<String, String>>{};
    for (final l in AppLanguage.values) {
      final c = l.code;
      if (c == null || c == 'en') continue;
      try {
        final raw = await rootBundle.loadString('assets/l10n/$c.json');
        all[c] = (jsonDecode(raw) as Map).cast<String, String>();
      } catch (_) {
        // A missing file just means English for that language.
      }
    }
    _all = all;
  }

  static void use(String languageCode) {
    code = languageCode;
    current = _all[languageCode] ?? const {};
  }

  /// For tests.
  static void setForTest(String languageCode, Map<String, String> strings) {
    _all = {..._all, languageCode: strings};
    use(languageCode);
  }
}

/// Translates [en] into the interface language. `{0}`, `{1}`… in the
/// English text are replaced by [args] after translation.
String tr(String en, [List<Object?> args = const []]) {
  var s = AppStrings.current[en] ?? en;
  for (var i = 0; i < args.length; i++) {
    s = s.replaceAll('{$i}', '${args[i]}');
  }
  return s;
}

/// A [Text] whose English string is translated; can be const.
class Tr extends StatelessWidget {
  const Tr(
    this.en, {
    super.key,
    this.args = const [],
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });
  final String en;
  final List<Object?> args;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) => Text(
    tr(en, args),
    style: style,
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    softWrap: softWrap,
  );
}
