import 'package:flutter/material.dart';

/// One set of colour tokens from the Organic design system
/// (docs/03-design-system.md). Light comes from the design; dark is
/// provisional until designed [OQ-10].
class Palette {
  const Palette({
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.neutral100,
    required this.neutral200,
    required this.neutral300,
    required this.neutral400,
    required this.neutral500,
    required this.neutral600,
    required this.neutral700,
    required this.neutral800,
    required this.text,
    required this.divider,
    required this.accent200,
    required this.accent400,
    required this.accent700,
    required this.accent900,
    required this.onAccent,
    required this.sage200,
    required this.sage300,
    required this.sage400,
    required this.sage600,
    required this.sage900,
    required this.moods,
  });

  final Brightness brightness;
  final Color bg, surface, text, divider;
  final Color neutral100, neutral200, neutral300, neutral400, neutral500;
  final Color neutral600, neutral700, neutral800;
  final Color accent200, accent400, accent700, accent900, onAccent;
  final Color sage200, sage300, sage400, sage600, sage900;

  /// rough, low, okay, good, bright
  final List<Color> moods;

  static const light = Palette(
    brightness: Brightness.light,
    bg: Color(0xFFF5EAD8),
    surface: Color(0xFFEBDDC5),
    neutral100: Color(0xFFFBF5EC),
    neutral200: Color(0xFFEFE5D6),
    neutral300: Color(0xFFDCD3C4),
    neutral400: Color(0xFFC0B6A5),
    neutral500: Color(0xFF9E9483),
    neutral600: Color(0xFF7D7465),
    neutral700: Color(0xFF665D50), // 4.5:1+ on surface
    neutral800: Color(0xFF4A433A),
    text: Color(0xFF201E1D),
    divider: Color(0xFFD9CCB6),
    accent200: Color(0xFFFFE1D0),
    accent400: Color(0xFFF6A06B),
    accent700: Color(0xFF8C491A),
    accent900: Color(0xFF5A2A0C),
    onAccent: Color(0xFFFFFFFF),
    sage200: Color(0xFFDDE6CC),
    sage300: Color(0xFFCCDBB2),
    sage400: Color(0xFFAEBF92),
    sage600: Color(0xFF728157),
    sage900: Color(0xFF2F3A22),
    moods: [
      Color(0xFF8C491A),
      Color(0xFFF6A06B),
      Color(0xFFC0B6A5),
      Color(0xFFAEBF92),
      Color(0xFF728157),
    ],
  );

  static const dark = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF171512),
    surface: Color(0xFF221F1B),
    neutral100: Color(0xFF2B2722),
    neutral200: Color(0xFF332E28),
    neutral300: Color(0xFF3E3830),
    neutral400: Color(0xFF6B6255),
    neutral500: Color(0xFF857B6C),
    neutral600: Color(0xFFA0968A),
    neutral700: Color(0xFFB9AF9F),
    neutral800: Color(0xFFD6CCBC),
    text: Color(0xFFF3EBDD),
    divider: Color(0xFF3A342C),
    accent200: Color(0xFF3A2418),
    accent400: Color(0xFFF6A06B),
    accent700: Color(0xFFF0A577),
    accent900: Color(0xFFFFE1D0),
    onAccent: Color(0xFF2A160A),
    sage200: Color(0xFF2C3424),
    sage300: Color(0xFF3B4630),
    sage400: Color(0xFF8FA374),
    sage600: Color(0xFFAEBF92),
    sage900: Color(0xFFE3ECD3),
    moods: [
      Color(0xFFD9774A),
      Color(0xFFF6A06B),
      Color(0xFF8A8172),
      Color(0xFF8FA374),
      Color(0xFFC3D4A5),
    ],
  );
}

/// The active palette. Feature widgets use these names, never hex. The app
/// root sets [current] from the theme and rebuilds the tree when it changes.
abstract final class AppColors {
  static Palette current = Palette.light;

  static Color get bg => current.bg;
  static Color get surface => current.surface;
  static Color get neutral100 => current.neutral100;
  static Color get neutral200 => current.neutral200;
  static Color get neutral300 => current.neutral300;
  static Color get neutral400 => current.neutral400;
  static Color get neutral500 => current.neutral500;
  static Color get neutral600 => current.neutral600;
  static Color get neutral700 => current.neutral700;
  static Color get neutral800 => current.neutral800;
  static Color get text => current.text;
  static Color get divider => current.divider;
  static Color get accent200 => current.accent200;
  static Color get accent400 => current.accent400;
  static Color get accent700 => current.accent700;
  static Color get accent900 => current.accent900;
  static Color get onAccent => current.onAccent;
  static Color get sage200 => current.sage200;
  static Color get sage300 => current.sage300;
  static Color get sage400 => current.sage400;
  static Color get sage600 => current.sage600;
  static Color get sage900 => current.sage900;
  static List<Color> get moods => current.moods;
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
TextStyle heading(double size, {Color? color}) => TextStyle(
  fontFamily: 'Fraunces',
  fontVariations: _headingVariations,
  fontSize: size,
  height: 1.15,
  color: color ?? AppColors.text,
);

TextStyle get arabicStyle => TextStyle(
  fontFamily: 'AmiriQuran',
  fontSize: 22,
  height: 1.9,
  color: AppColors.neutral800,
);

TextStyle meta({Color? color, double size = 12}) =>
    TextStyle(fontSize: size, color: color ?? AppColors.neutral700);

ThemeData buildTheme(Palette p) {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: p.sage600,
        brightness: p.brightness,
      ).copyWith(
        primary: p.accent700,
        onPrimary: p.onAccent,
        secondary: p.sage600,
        surface: p.bg,
        onSurface: p.text,
        outline: p.divider,
      );
  return ThemeData(
    useMaterial3: true,
    brightness: p.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.bg,
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: p.text),
      bodyMedium: TextStyle(fontSize: 15, color: p.text),
      bodySmall: TextStyle(fontSize: 12, color: p.neutral700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.neutral100,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: p.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: p.divider),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: p.accent700,
        minimumSize: const Size(64, 44),
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: p.accent700,
        minimumSize: const Size(44, 40),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.text,
        side: BorderSide(color: p.divider),
        minimumSize: const Size(44, 40),
        shape: const StadiumBorder(),
      ),
    ),
  );
}
