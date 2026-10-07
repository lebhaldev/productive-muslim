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

  /// Ocean: deep blue actions, teal in place of sage.
  static const oceanLight = Palette(
    brightness: Brightness.light,
    bg: Color(0xFFEEF2F3),
    surface: Color(0xFFDFE7EA),
    neutral100: Color(0xFFF7FAFA),
    neutral200: Color(0xFFE6ECEE),
    neutral300: Color(0xFFD0D9DC),
    neutral400: Color(0xFFAEBBC0),
    neutral500: Color(0xFF8B999F),
    neutral600: Color(0xFF6B7A80),
    neutral700: Color(0xFF4F5D63),
    neutral800: Color(0xFF36434A),
    text: Color(0xFF142026),
    divider: Color(0xFFCAD5D9),
    accent200: Color(0xFFD6EAF4),
    accent400: Color(0xFF5FA7C9),
    accent700: Color(0xFF1F5C78),
    accent900: Color(0xFF0E3346),
    onAccent: Color(0xFFFFFFFF),
    sage200: Color(0xFFD3EAE6),
    sage300: Color(0xFFB9DDD6),
    sage400: Color(0xFF8CC2B8),
    sage600: Color(0xFF3E7F74),
    sage900: Color(0xFF173A35),
    moods: [
      Color(0xFFA04A3A),
      Color(0xFFE3A27A),
      Color(0xFFAEBBC0),
      Color(0xFF8CC2B8),
      Color(0xFF3E7F74),
    ],
  );

  static const oceanDark = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF0F1518),
    surface: Color(0xFF172024),
    neutral100: Color(0xFF1D282D),
    neutral200: Color(0xFF243035),
    neutral300: Color(0xFF2E3B41),
    neutral400: Color(0xFF55666D),
    neutral500: Color(0xFF708187),
    neutral600: Color(0xFF8E9EA4),
    neutral700: Color(0xFFAAB8BD),
    neutral800: Color(0xFFCBD6DA),
    text: Color(0xFFE8F0F2),
    divider: Color(0xFF2A363B),
    accent200: Color(0xFF15303D),
    accent400: Color(0xFF6FB3D2),
    accent700: Color(0xFF8CC8E3),
    accent900: Color(0xFFD6EEF8),
    onAccent: Color(0xFF0A1E28),
    sage200: Color(0xFF183430),
    sage300: Color(0xFF22463F),
    sage400: Color(0xFF5FA396),
    sage600: Color(0xFF8CC2B8),
    sage900: Color(0xFFD3EEE9),
    moods: [
      Color(0xFFC96B5A),
      Color(0xFFE3A27A),
      Color(0xFF7E8C92),
      Color(0xFF5FA396),
      Color(0xFF8CC2B8),
    ],
  );

  /// Desert: rose actions, olive gold in place of sage.
  static const desertLight = Palette(
    brightness: Brightness.light,
    bg: Color(0xFFF8EFE7),
    surface: Color(0xFFEFE0D3),
    neutral100: Color(0xFFFCF7F2),
    neutral200: Color(0xFFF1E6DC),
    neutral300: Color(0xFFE0D2C5),
    neutral400: Color(0xFFC5B5A6),
    neutral500: Color(0xFFA39384),
    neutral600: Color(0xFF827365),
    neutral700: Color(0xFF67594C),
    neutral800: Color(0xFF4B4037),
    text: Color(0xFF231C18),
    divider: Color(0xFFDFCDBE),
    accent200: Color(0xFFF6D9DE),
    accent400: Color(0xFFD98A98),
    accent700: Color(0xFF8A3B4A),
    accent900: Color(0xFF561E2A),
    onAccent: Color(0xFFFFFFFF),
    sage200: Color(0xFFEFE5C8),
    sage300: Color(0xFFE5D6A9),
    sage400: Color(0xFFCDB77E),
    sage600: Color(0xFF86702F),
    sage900: Color(0xFF3B2F10),
    moods: [
      Color(0xFF8A3B4A),
      Color(0xFFD98A98),
      Color(0xFFC5B5A6),
      Color(0xFFCDB77E),
      Color(0xFF86702F),
    ],
  );

  static const desertDark = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF18130F),
    surface: Color(0xFF231C17),
    neutral100: Color(0xFF2C241E),
    neutral200: Color(0xFF352B24),
    neutral300: Color(0xFF40352C),
    neutral400: Color(0xFF6E6155),
    neutral500: Color(0xFF887A6D),
    neutral600: Color(0xFFA3958A),
    neutral700: Color(0xFFBDB0A3),
    neutral800: Color(0xFFD9CDC1),
    text: Color(0xFFF4EBE2),
    divider: Color(0xFF3C3129),
    accent200: Color(0xFF3B1D24),
    accent400: Color(0xFFE59AA8),
    accent700: Color(0xFFEFA9B6),
    accent900: Color(0xFFFBDDE3),
    onAccent: Color(0xFF2B0E15),
    sage200: Color(0xFF33301E),
    sage300: Color(0xFF48422A),
    sage400: Color(0xFFB39C5E),
    sage600: Color(0xFFD2BC7E),
    sage900: Color(0xFFF1E7C6),
    moods: [
      Color(0xFFD96F80),
      Color(0xFFE59AA8),
      Color(0xFF8A7D70),
      Color(0xFFB39C5E),
      Color(0xFFD2BC7E),
    ],
  );

  /// Night: true black for OLED screens; always dark.
  static const night = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF000000),
    surface: Color(0xFF111311),
    neutral100: Color(0xFF181A18),
    neutral200: Color(0xFF1F221F),
    neutral300: Color(0xFF2A2E2A),
    neutral400: Color(0xFF555B54),
    neutral500: Color(0xFF737A72),
    neutral600: Color(0xFF939A91),
    neutral700: Color(0xFFB1B8AF),
    neutral800: Color(0xFFD2D8CF),
    text: Color(0xFFEEF2EA),
    divider: Color(0xFF262A25),
    accent200: Color(0xFF3A2418),
    accent400: Color(0xFFF6A06B),
    accent700: Color(0xFFF0A577),
    accent900: Color(0xFFFFE1D0),
    onAccent: Color(0xFF2A160A),
    sage200: Color(0xFF1C2418),
    sage300: Color(0xFF2B3622),
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

  /// Emerald: deep green actions, olive in place of sage.
  static const emeraldLight = Palette(
    brightness: Brightness.light,
    bg: Color(0xFFF1F5EF),
    surface: Color(0xFFE1EBDD),
    neutral100: Color(0xFFF8FBF6),
    neutral200: Color(0xFFE8F0E4),
    neutral300: Color(0xFFD3DECE),
    neutral400: Color(0xFFB3C2AC),
    neutral500: Color(0xFF90A088),
    neutral600: Color(0xFF6E7E67),
    neutral700: Color(0xFF52614C),
    neutral800: Color(0xFF394535),
    text: Color(0xFF16201A),
    divider: Color(0xFFCFDCC9),
    accent200: Color(0xFFD7EBDF),
    accent400: Color(0xFF6FB894),
    accent700: Color(0xFF1C6B48),
    accent900: Color(0xFF0E3D28),
    onAccent: Color(0xFFFFFFFF),
    sage200: Color(0xFFE8EDCF),
    sage300: Color(0xFFD6E0B0),
    sage400: Color(0xFFB8C784),
    sage600: Color(0xFF6B7A2E),
    sage900: Color(0xFF2E3612),
    moods: [
      Color(0xFF8A3B2E),
      Color(0xFFD9905F),
      Color(0xFFB3C2AC),
      Color(0xFF6FB894),
      Color(0xFF1C6B48),
    ],
  );

  static const emeraldDark = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF0E1511),
    surface: Color(0xFF16201A),
    neutral100: Color(0xFF1C2821),
    neutral200: Color(0xFF23302A),
    neutral300: Color(0xFF2D3B33),
    neutral400: Color(0xFF55665B),
    neutral500: Color(0xFF708276),
    neutral600: Color(0xFF8EA093),
    neutral700: Color(0xFFAABBAE),
    neutral800: Color(0xFFCADACF),
    text: Color(0xFFE8F2EB),
    divider: Color(0xFF28362D),
    accent200: Color(0xFF143024),
    accent400: Color(0xFF5FB88C),
    accent700: Color(0xFF86D1AC),
    accent900: Color(0xFFD4F2E2),
    onAccent: Color(0xFF0A2216),
    sage200: Color(0xFF2A3018),
    sage300: Color(0xFF3B4422),
    sage400: Color(0xFFA3B26A),
    sage600: Color(0xFFC5D38F),
    sage900: Color(0xFFEDF3D3),
    moods: [
      Color(0xFFD9774A),
      Color(0xFFE7A26F),
      Color(0xFF7E8C82),
      Color(0xFF5FB88C),
      Color(0xFF86D1AC),
    ],
  );

  /// Rose: rose actions, soft green in place of sage.
  static const roseLight = Palette(
    brightness: Brightness.light,
    bg: Color(0xFFFAF0F0),
    surface: Color(0xFFF2E1E2),
    neutral100: Color(0xFFFDF7F7),
    neutral200: Color(0xFFF5E9EA),
    neutral300: Color(0xFFE6D3D5),
    neutral400: Color(0xFFCBB2B5),
    neutral500: Color(0xFFA88E92),
    neutral600: Color(0xFF86696E),
    neutral700: Color(0xFF6A5055),
    neutral800: Color(0xFF4C373B),
    text: Color(0xFF241A1C),
    divider: Color(0xFFE5CDD0),
    accent200: Color(0xFFF7D9DF),
    accent400: Color(0xFFDE8A9C),
    accent700: Color(0xFF9A3550),
    accent900: Color(0xFF5E1A2E),
    onAccent: Color(0xFFFFFFFF),
    sage200: Color(0xFFE3EADF),
    sage300: Color(0xFFCDDBC6),
    sage400: Color(0xFFA7BD9C),
    sage600: Color(0xFF557447),
    sage900: Color(0xFF23331B),
    moods: [
      Color(0xFF9A3550),
      Color(0xFFDE8A9C),
      Color(0xFFCBB2B5),
      Color(0xFFA7BD9C),
      Color(0xFF557447),
    ],
  );

  static const roseDark = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF1A1214),
    surface: Color(0xFF251A1D),
    neutral100: Color(0xFF2F2226),
    neutral200: Color(0xFF382A2E),
    neutral300: Color(0xFF443337),
    neutral400: Color(0xFF70595E),
    neutral500: Color(0xFF8B7378),
    neutral600: Color(0xFFA68F94),
    neutral700: Color(0xFFBFA9AE),
    neutral800: Color(0xFFDCCACE),
    text: Color(0xFFF6EAEC),
    divider: Color(0xFF3F2E33),
    accent200: Color(0xFF3E1A25),
    accent400: Color(0xFFE890A4),
    accent700: Color(0xFFF2AABA),
    accent900: Color(0xFFFDDDE5),
    onAccent: Color(0xFF2E0C17),
    sage200: Color(0xFF24301F),
    sage300: Color(0xFF33442B),
    sage400: Color(0xFF8EAD80),
    sage600: Color(0xFFB4CFA6),
    sage900: Color(0xFFE1EFD9),
    moods: [
      Color(0xFFE06A7E),
      Color(0xFFE890A4),
      Color(0xFF8A777B),
      Color(0xFF8EAD80),
      Color(0xFFB4CFA6),
    ],
  );

  /// Dusk: indigo actions, warm amber in place of sage.
  static const duskLight = Palette(
    brightness: Brightness.light,
    bg: Color(0xFFF2F1F8),
    surface: Color(0xFFE4E2F0),
    neutral100: Color(0xFFF9F8FC),
    neutral200: Color(0xFFEBE9F4),
    neutral300: Color(0xFFD7D4E6),
    neutral400: Color(0xFFB7B3CC),
    neutral500: Color(0xFF9792AE),
    neutral600: Color(0xFF76718F),
    neutral700: Color(0xFF5A5573),
    neutral800: Color(0xFF3F3B55),
    text: Color(0xFF1B1A26),
    divider: Color(0xFFD3D0E3),
    accent200: Color(0xFFE1DCF5),
    accent400: Color(0xFF9C8FD6),
    accent700: Color(0xFF4B3F8C),
    accent900: Color(0xFF2B2257),
    onAccent: Color(0xFFFFFFFF),
    sage200: Color(0xFFF5E6D3),
    sage300: Color(0xFFEBD2B2),
    sage400: Color(0xFFD6AE7E),
    sage600: Color(0xFF8C5E24),
    sage900: Color(0xFF3E290F),
    moods: [
      Color(0xFF8C3B4B),
      Color(0xFFD6AE7E),
      Color(0xFFB7B3CC),
      Color(0xFF9C8FD6),
      Color(0xFF4B3F8C),
    ],
  );

  static const duskDark = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF12111A),
    surface: Color(0xFF1B1A26),
    neutral100: Color(0xFF232231),
    neutral200: Color(0xFF2B2A3B),
    neutral300: Color(0xFF363447),
    neutral400: Color(0xFF5D5A72),
    neutral500: Color(0xFF78748E),
    neutral600: Color(0xFF9792AB),
    neutral700: Color(0xFFB2AEC4),
    neutral800: Color(0xFFD2CFE0),
    text: Color(0xFFEEECF6),
    divider: Color(0xFF322F42),
    accent200: Color(0xFF2A2448),
    accent400: Color(0xFFA79AE6),
    accent700: Color(0xFFBDB2F2),
    accent900: Color(0xFFE5E0FC),
    onAccent: Color(0xFF1A1433),
    sage200: Color(0xFF3A2C1A),
    sage300: Color(0xFF503C22),
    sage400: Color(0xFFC99F6B),
    sage600: Color(0xFFE3C08F),
    sage900: Color(0xFFF6E6CF),
    moods: [
      Color(0xFFD9728A),
      Color(0xFFE3C08F),
      Color(0xFF7F7B93),
      Color(0xFFA79AE6),
      Color(0xFFBDB2F2),
    ],
  );

  /// Slate: steel blue actions on cool greys, olive in place of sage.
  static const slateLight = Palette(
    brightness: Brightness.light,
    bg: Color(0xFFF2F3F4),
    surface: Color(0xFFE4E6E8),
    neutral100: Color(0xFFF9FAFA),
    neutral200: Color(0xFFEBEDEE),
    neutral300: Color(0xFFD6D9DC),
    neutral400: Color(0xFFB5BABF),
    neutral500: Color(0xFF92989E),
    neutral600: Color(0xFF71777E),
    neutral700: Color(0xFF555B61),
    neutral800: Color(0xFF3B4045),
    text: Color(0xFF17191B),
    divider: Color(0xFFD2D6D9),
    accent200: Color(0xFFDCE3EA),
    accent400: Color(0xFF7F98AE),
    accent700: Color(0xFF35526B),
    accent900: Color(0xFF1C3043),
    onAccent: Color(0xFFFFFFFF),
    sage200: Color(0xFFE6E8DF),
    sage300: Color(0xFFD2D6C6),
    sage400: Color(0xFFAEB59A),
    sage600: Color(0xFF5E6650),
    sage900: Color(0xFF262A1F),
    moods: [
      Color(0xFF8A4A3A),
      Color(0xFFC99A6E),
      Color(0xFFB5BABF),
      Color(0xFF7F98AE),
      Color(0xFF35526B),
    ],
  );

  static const slateDark = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF111315),
    surface: Color(0xFF1A1D20),
    neutral100: Color(0xFF212528),
    neutral200: Color(0xFF282C30),
    neutral300: Color(0xFF33383D),
    neutral400: Color(0xFF586066),
    neutral500: Color(0xFF737B82),
    neutral600: Color(0xFF91999F),
    neutral700: Color(0xFFAEB5BA),
    neutral800: Color(0xFFCED4D8),
    text: Color(0xFFECEFF1),
    divider: Color(0xFF30353A),
    accent200: Color(0xFF1E2B37),
    accent400: Color(0xFF8AA6BF),
    accent700: Color(0xFFA8C0D4),
    accent900: Color(0xFFDCE7F0),
    onAccent: Color(0xFF0F1A24),
    sage200: Color(0xFF262A1F),
    sage300: Color(0xFF353A2B),
    sage400: Color(0xFFA3AB8C),
    sage600: Color(0xFFC4CBAF),
    sage900: Color(0xFFE9ECDF),
    moods: [
      Color(0xFFD27A62),
      Color(0xFFC99A6E),
      Color(0xFF7A8288),
      Color(0xFF8AA6BF),
      Color(0xFFA8C0D4),
    ],
  );
}

/// Colour themes the user can pick (Settings → Appearance). Sage is the
/// design; the others are provisional until designed (DS-1).
enum ColorTheme {
  sage('Sage', Palette.light, Palette.dark),
  ocean('Ocean', Palette.oceanLight, Palette.oceanDark),
  desert('Desert', Palette.desertLight, Palette.desertDark),
  emerald('Emerald', Palette.emeraldLight, Palette.emeraldDark),
  rose('Rose', Palette.roseLight, Palette.roseDark),
  dusk('Dusk', Palette.duskLight, Palette.duskDark),
  slate('Slate', Palette.slateLight, Palette.slateDark),
  night('Night', Palette.night, Palette.night);

  const ColorTheme(this.label, this.light, this.dark);
  final String label;
  final Palette light;
  final Palette dark;

  /// Night has no light variant, so it ignores the light/dark choice.
  bool get alwaysDark => light == dark;

  Palette paletteFor(Brightness b) => b == Brightness.dark ? dark : light;
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
