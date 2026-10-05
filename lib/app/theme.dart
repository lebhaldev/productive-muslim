import 'package:flutter/material.dart';

/// Colour tokens from the Organic design system used by the Nurday design
/// (docs/03-design-system.md). Feature widgets use these names, never hex.
abstract final class AppColors {
  static const bg = Color(0xFFF5EAD8);
  static const surface = Color(0xFFEBDDC5);
  static const neutral100 = Color(0xFFFBF5EC);
  static const neutral200 = Color(0xFFEFE5D6);
  static const neutral300 = Color(0xFFDCD3C4);
  static const neutral400 = Color(0xFFC0B6A5);
  static const neutral500 = Color(0xFF9E9483);
  static const neutral600 = Color(0xFF7D7465);
  static const neutral700 = Color(0xFF665D50); // 4.5:1+ on surface
  static const neutral800 = Color(0xFF4A433A);
  static const text = Color(0xFF201E1D);
  static const divider = Color(0xFFD9CCB6);

  static const accent200 = Color(0xFFFFE1D0);
  static const accent400 = Color(0xFFF6A06B);
  static const accent700 = Color(0xFF8C491A);
  static const accent900 = Color(0xFF5A2A0C);

  static const sage200 = Color(0xFFDDE6CC);
  static const sage300 = Color(0xFFCCDBB2);
  static const sage400 = Color(0xFFAEBF92);
  static const sage600 = Color(0xFF728157);
  static const sage900 = Color(0xFF2F3A22);

  /// rough, low, okay, good, bright
  static const moods = [accent700, accent400, neutral400, sage400, sage600];
}

abstract final class AppRadii {
  static const md = 12.0;
  static const lg = 20.0;
  static const pill = 999.0;
}

const _headingVariations = [
  FontVariation('wght', 640),
  FontVariation('SOFT', 100),
];

/// Display serif used for titles and section headings.
TextStyle heading(double size, {Color color = AppColors.text}) => TextStyle(
  fontFamily: 'Fraunces',
  fontVariations: _headingVariations,
  fontSize: size,
  height: 1.15,
  color: color,
);

const arabicStyle = TextStyle(
  fontFamily: 'AmiriQuran',
  fontSize: 22,
  height: 1.9,
  color: AppColors.neutral800,
);

TextStyle meta({Color color = AppColors.neutral700, double size = 12}) =>
    TextStyle(fontSize: size, color: color);

ThemeData buildTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.sage600,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.accent700,
        onPrimary: Colors.white,
        secondary: AppColors.sage600,
        surface: AppColors.bg,
        onSurface: AppColors.text,
        outline: AppColors.divider,
      );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: AppColors.text),
      bodyMedium: TextStyle(fontSize: 15, color: AppColors.text),
      bodySmall: TextStyle(fontSize: 12, color: AppColors.neutral700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.neutral100,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent700,
        minimumSize: const Size(64, 44),
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent700,
        minimumSize: const Size(44, 40),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        side: const BorderSide(color: AppColors.divider),
        minimumSize: const Size(44, 40),
        shape: const StadiumBorder(),
      ),
    ),
  );
}
