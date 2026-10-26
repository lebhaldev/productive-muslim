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
    bg: Color(0xFF1D1B18),
    surface: Color(0xFF2A2723),
    neutral100: Color(0xFF25221E),
    neutral200: Color(0xFF322E29),
    neutral300: Color(0xFF3D3832),
    neutral400: Color(0xFF5A534A),
    neutral500: Color(0xFF776F63),
    neutral600: Color(0xFF8F8678),
    neutral700: Color(0xFFB3A998),
    neutral800: Color(0xFFD4CAB9),
    text: Color(0xFFF1E8DA),
    divider: Color(0xFF3D3832),
    accent200: Color(0xFF3D2A1D),
    accent400: Color(0xFFC9814F),
    accent700: Color(0xFFE7A375),
    accent900: Color(0xFFFFE1D0),
    onAccent: Color(0xFF2A160A),
    sage200: Color(0xFF2F3826),
    sage300: Color(0xFF3C4831),
    sage400: Color(0xFF6F8257),
    sage600: Color(0xFFA3B788),
    sage900: Color(0xFFDFE9CF),
    moods: [
      Color(0xFFD9774A),
      Color(0xFFF6A06B),
      Color(0xFF8A8172),
      Color(0xFF6F8257),
      Color(0xFFA3B788),
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

  /// Lavender: violet actions, rose in place of sage.
  static const lavenderLight = Palette(
    brightness: Brightness.light,
    bg: Color(0xFFF5F4F6),
    surface: Color(0xFFE8E5EB),
    neutral100: Color(0xFFFAF9FB),
    neutral200: Color(0xFFEDEBEF),
    neutral300: Color(0xFFDBD7E0),
    neutral400: Color(0xFFBDB5C5),
    neutral500: Color(0xFF9E92AA),
    neutral600: Color(0xFF7F708F),
    neutral700: Color(0xFF5C5167),
    neutral800: Color(0xFF453D4D),
    text: Color(0xFF1C191F),
    divider: Color(0xFFD6D1DB),
    accent200: Color(0xFFEAE1F4),
    accent400: Color(0xFF9B72CA),
    accent700: Color(0xFF522E7A),
    accent900: Color(0xFF2F1B46),
    onAccent: Color(0xFFFFFFFF),
    sage200: Color(0xFFEEDDE6),
    sage300: Color(0xFFE3C4D4),
    sage400: Color(0xFFC78AA8),
    sage600: Color(0xFF7C3C5C),
    sage900: Color(0xFF3B1C2B),
    moods: [
      Color(0xFFA64030),
      Color(0xFF9B72CA),
      Color(0xFFBDB5C5),
      Color(0xFFC78AA8),
      Color(0xFF7C3C5C),
    ],
  );

  static const lavenderDark = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF121014),
    surface: Color(0xFF1C191F),
    neutral100: Color(0xFF241F28),
    neutral200: Color(0xFF2B2631),
    neutral300: Color(0xFF362F3C),
    neutral400: Color(0xFF5E536A),
    neutral500: Color(0xFF7A6C89),
    neutral600: Color(0xFF998DA5),
    neutral700: Color(0xFFB8AFC0),
    neutral800: Color(0xFFD6D1DB),
    text: Color(0xFFEDEBEF),
    divider: Color(0xFF2E2833),
    accent200: Color(0xFF2A183F),
    accent400: Color(0xFFA07ACD),
    accent700: Color(0xFFBB9FDB),
    accent900: Color(0xFFE5DAF1),
    onAccent: Color(0xFF190E25),
    sage200: Color(0xFF371B29),
    sage300: Color(0xFF4F263B),
    sage400: Color(0xFFAF5A85),
    sage600: Color(0xFFCD98B2),
    sage900: Color(0xFFEEDDE6),
    moods: [
      Color(0xFFD17061),
      Color(0xFFA07ACD),
      Color(0xFF5E536A),
      Color(0xFFAF5A85),
      Color(0xFFCD98B2),
    ],
  );

  /// Sunrise: warm orange actions, amber in place of sage.
  static const sunriseLight = Palette(
    brightness: Brightness.light,
    bg: Color(0xFFF7F5F3),
    surface: Color(0xFFEDE8E3),
    neutral100: Color(0xFFFBFAF9),
    neutral200: Color(0xFFF1EDE9),
    neutral300: Color(0xFFE3DBD3),
    neutral400: Color(0xFFCBBDAE),
    neutral500: Color(0xFFB39E89),
    neutral600: Color(0xFF9C8063),
    neutral700: Color(0xFF705C48),
    neutral800: Color(0xFF544536),
    text: Color(0xFF221C16),
    divider: Color(0xFFDFD6CD),
    accent200: Color(0xFFF9E4DC),
    accent400: Color(0xFFE27E5A),
    accent700: Color(0xFF8F3919),
    accent900: Color(0xFF52210F),
    onAccent: Color(0xFFFFFFFF),
    sage200: Color(0xFFF5ECD6),
    sage300: Color(0xFFEEDEBA),
    sage400: Color(0xFFDCBD74),
    sage600: Color(0xFF937225),
    sage900: Color(0xFF453611),
    moods: [
      Color(0xFFA64030),
      Color(0xFFE27E5A),
      Color(0xFFCBBDAE),
      Color(0xFFDCBD74),
      Color(0xFF937225),
    ],
  );

  static const sunriseDark = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF16120E),
    surface: Color(0xFF221C16),
    neutral100: Color(0xFF2C241C),
    neutral200: Color(0xFF352B22),
    neutral300: Color(0xFF41362A),
    neutral400: Color(0xFF735E4A),
    neutral500: Color(0xFF957A5F),
    neutral600: Color(0xFFAF9983),
    neutral700: Color(0xFFC7B8A8),
    neutral800: Color(0xFFDFD6CD),
    text: Color(0xFFF1EDE9),
    divider: Color(0xFF382E24),
    accent200: Color(0xFF4A1D0D),
    accent400: Color(0xFFE38563),
    accent700: Color(0xFFEBA78E),
    accent900: Color(0xFFF7DDD4),
    onAccent: Color(0xFF2B1108),
    sage200: Color(0xFF413310),
    sage300: Color(0xFF5E4917),
    sage400: Color(0xFFCEA23B),
    sage600: Color(0xFFE0C585),
    sage900: Color(0xFFF5ECD6),
    moods: [
      Color(0xFFD17061),
      Color(0xFFE38563),
      Color(0xFF735E4A),
      Color(0xFFCEA23B),
      Color(0xFFE0C585),
    ],
  );

  /// Indigo: deep blue actions, teal in place of sage.
  static const indigoLight = Palette(
    brightness: Brightness.light,
    bg: Color(0xFFF3F4F6),
    surface: Color(0xFFE5E6EB),
    neutral100: Color(0xFFF9F9FB),
    neutral200: Color(0xFFEBECF0),
    neutral300: Color(0xFFD6D8E0),
    neutral400: Color(0xFFB3B7C6),
    neutral500: Color(0xFF9196AC),
    neutral600: Color(0xFF6E7591),
    neutral700: Color(0xFF4F5469),
    neutral800: Color(0xFF3B3F4E),
    text: Color(0xFF181A20),
    divider: Color(0xFFD0D3DC),
    accent200: Color(0xFFE0E3F5),
    accent400: Color(0xFF6E7BCF),
    accent700: Color(0xFF2A357E),
    accent900: Color(0xFF181F49),
    onAccent: Color(0xFFFFFFFF),
    sage200: Color(0xFFDBF0EE),
    sage300: Color(0xFFC2E5E3),
    sage400: Color(0xFF86CBC6),
    sage600: Color(0xFF37817C),
    sage900: Color(0xFF1A3D3A),
    moods: [
      Color(0xFFA64030),
      Color(0xFF6E7BCF),
      Color(0xFFB3B7C6),
      Color(0xFF86CBC6),
      Color(0xFF37817C),
    ],
  );

  static const indigoDark = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF0F1014),
    surface: Color(0xFF181A20),
    neutral100: Color(0xFF1F2129),
    neutral200: Color(0xFF252831),
    neutral300: Color(0xFF2E313D),
    neutral400: Color(0xFF51566C),
    neutral500: Color(0xFF69708C),
    neutral600: Color(0xFF8B90A7),
    neutral700: Color(0xFFAEB2C2),
    neutral800: Color(0xFFD0D3DC),
    text: Color(0xFFEBECF0),
    divider: Color(0xFF272A34),
    accent200: Color(0xFF161B41),
    accent400: Color(0xFF7582D1),
    accent700: Color(0xFF9CA4DE),
    accent900: Color(0xFFD9DCF2),
    onAccent: Color(0xFF0D1026),
    sage200: Color(0xFF183937),
    sage300: Color(0xFF23524F),
    sage400: Color(0xFF54B6AF),
    sage600: Color(0xFF94D1CD),
    sage900: Color(0xFFDBF0EE),
    moods: [
      Color(0xFFD17061),
      Color(0xFF7582D1),
      Color(0xFF51566C),
      Color(0xFF54B6AF),
      Color(0xFF94D1CD),
    ],
  );

  /// Mono: graphite and grey, for a quiet screen.
  static const monoLight = Palette(
    brightness: Brightness.light,
    bg: Color(0xFFF5F5F5),
    surface: Color(0xFFE8E8E8),
    neutral100: Color(0xFFFAFAFA),
    neutral200: Color(0xFFEDEDED),
    neutral300: Color(0xFFDBDBDB),
    neutral400: Color(0xFFBDBDBD),
    neutral500: Color(0xFF9E9E9E),
    neutral600: Color(0xFF808080),
    neutral700: Color(0xFF5C5C5C),
    neutral800: Color(0xFF454545),
    text: Color(0xFF1C1C1C),
    divider: Color(0xFFD6D6D6),
    accent200: Color(0xFFE9EAEC),
    accent400: Color(0xFF969CA6),
    accent700: Color(0xFF4D525B),
    accent900: Color(0xFF2D2F34),
    onAccent: Color(0xFFFFFFFF),
    sage200: Color(0xFFE4E6E7),
    sage300: Color(0xFFD1D5D6),
    sage400: Color(0xFFA3AAAE),
    sage600: Color(0xFF565E61),
    sage900: Color(0xFF292C2E),
    moods: [
      Color(0xFFA64030),
      Color(0xFF969CA6),
      Color(0xFFBDBDBD),
      Color(0xFFA3AAAE),
      Color(0xFF565E61),
    ],
  );

  static const monoDark = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF121212),
    surface: Color(0xFF1C1C1C),
    neutral100: Color(0xFF242424),
    neutral200: Color(0xFF2B2B2B),
    neutral300: Color(0xFF363636),
    neutral400: Color(0xFF5E5E5E),
    neutral500: Color(0xFF7A7A7A),
    neutral600: Color(0xFF999999),
    neutral700: Color(0xFFB8B8B8),
    neutral800: Color(0xFFD6D6D6),
    text: Color(0xFFEDEDED),
    divider: Color(0xFF2E2E2E),
    accent200: Color(0xFF282A2F),
    accent400: Color(0xFF9CA1AB),
    accent700: Color(0xFFB7BBC2),
    accent900: Color(0xFFE3E5E8),
    onAccent: Color(0xFF17191C),
    sage200: Color(0xFF262A2B),
    sage300: Color(0xFF373C3E),
    sage400: Color(0xFF7D878C),
    sage600: Color(0xFFAEB4B7),
    sage900: Color(0xFFE4E6E7),
    moods: [
      Color(0xFFD17061),
      Color(0xFF9CA1AB),
      Color(0xFF5E5E5E),
      Color(0xFF7D878C),
      Color(0xFFAEB4B7),
    ],
  );

  /// Mint: fresh mint with coral.
  static const mintLight = Palette(
    brightness: Brightness.light,
    bg: Color(0xFFECFBF4),
    surface: Color(0xFFD3F0E2),
    neutral100: Color(0xFFF7FEFA),
    neutral200: Color(0xFFE0F0E8),
    neutral300: Color(0xFFC6DAD0),
    neutral400: Color(0xFFA0AFA8),
    neutral500: Color(0xFF707E77),
    neutral600: Color(0xFF54615B),
    neutral700: Color(0xFF394D44),
    neutral800: Color(0xFF24382F),
    text: Color(0xFF071A13),
    divider: Color(0xFFBADACA),
    accent200: Color(0xFFFFDCD7),
    accent400: Color(0xFFF98F87),
    accent700: Color(0xFF963633),
    accent900: Color(0xFF521D1B),
    onAccent: Color(0xFFFFFFFF),
    sage200: Color(0xFFBDEFD7),
    sage300: Color(0xFF97E4C2),
    sage400: Color(0xFF5FCCA1),
    sage600: Color(0xFF00885E),
    sage900: Color(0xFF003825),
    moods: [
      Color(0xFF963633),
      Color(0xFFF98F87),
      Color(0xFFA0AFA8),
      Color(0xFF5FCCA1),
      Color(0xFF00885E),
    ],
  );

  static const mintDark = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF101916),
    surface: Color(0xFF182521),
    neutral100: Color(0xFF1F2D29),
    neutral200: Color(0xFF273531),
    neutral300: Color(0xFF30403B),
    neutral400: Color(0xFF556D65),
    neutral500: Color(0xFF6E877F),
    neutral600: Color(0xFF8FA39D),
    neutral700: Color(0xFFB1C4BE),
    neutral800: Color(0xFFD2E0DB),
    text: Color(0xFFEBF4F1),
    divider: Color(0xFF2B3B36),
    accent200: Color(0xFF401E1C),
    accent400: Color(0xFFF2635A),
    accent700: Color(0xFFF4827B),
    accent900: Color(0xFFFCD1CF),
    onAccent: Color(0xFF290C0A),
    sage200: Color(0xFF1E3830),
    sage300: Color(0xFF2B5044),
    sage400: Color(0xFF59C09F),
    sage600: Color(0xFF73D3B4),
    sage900: Color(0xFFD7F4EB),
    moods: [
      Color(0xFFDF5249),
      Color(0xFFF2635A),
      Color(0xFF6E877F),
      Color(0xFF59C09F),
      Color(0xFFABE3D1),
    ],
  );

  /// Sky: clear sky blue with apricot.
  static const skyLight = Palette(
    brightness: Brightness.light,
    bg: Color(0xFFECF9FF),
    surface: Color(0xFFD2ECFC),
    neutral100: Color(0xFFF7FDFF),
    neutral200: Color(0xFFDFEEF7),
    neutral300: Color(0xFFC5D7E3),
    neutral400: Color(0xFF9FADB6),
    neutral500: Color(0xFF6F7D85),
    neutral600: Color(0xFF536067),
    neutral700: Color(0xFF384B56),
    neutral800: Color(0xFF243540),
    text: Color(0xFF071822),
    divider: Color(0xFFB9D6E8),
    accent200: Color(0xFFFFE2C6),
    accent400: Color(0xFFE99F50),
    accent700: Color(0xFF8A4700),
    accent900: Color(0xFF4B2600),
    onAccent: Color(0xFFFFFFFF),
    sage200: Color(0xFFBBE9FF),
    sage300: Color(0xFF95DBFF),
    sage400: Color(0xFF5DC0F6),
    sage600: Color(0xFF007BB2),
    sage900: Color(0xFF00324C),
    moods: [
      Color(0xFF8A4700),
      Color(0xFFE99F50),
      Color(0xFF9FADB6),
      Color(0xFF5DC0F6),
      Color(0xFF007BB2),
    ],
  );

  static const skyDark = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF101619),
    surface: Color(0xFF182125),
    neutral100: Color(0xFF1F292D),
    neutral200: Color(0xFF273135),
    neutral300: Color(0xFF303B40),
    neutral400: Color(0xFF55656D),
    neutral500: Color(0xFF6E7F87),
    neutral600: Color(0xFF8F9DA3),
    neutral700: Color(0xFFB1BEC4),
    neutral800: Color(0xFFD2DBE0),
    text: Color(0xFFEBF1F4),
    divider: Color(0xFF2B363B),
    accent200: Color(0xFF402F1C),
    accent400: Color(0xFFF2AB5A),
    accent700: Color(0xFFF4BC7B),
    accent900: Color(0xFFFCE7CF),
    onAccent: Color(0xFF291B0A),
    sage200: Color(0xFF1E3038),
    sage300: Color(0xFF2B4450),
    sage400: Color(0xFF599FC0),
    sage600: Color(0xFF73B5D3),
    sage900: Color(0xFFD7EBF4),
    moods: [
      Color(0xFFDF9949),
      Color(0xFFF2AB5A),
      Color(0xFF6E7F87),
      Color(0xFF599FC0),
      Color(0xFFABD1E3),
    ],
  );

  /// Blossom: soft pink with green.
  static const blossomLight = Palette(
    brightness: Brightness.light,
    bg: Color(0xFFFFF2F8),
    surface: Color(0xFFFBDFEB),
    neutral100: Color(0xFFFFFAFC),
    neutral200: Color(0xFFF6E6ED),
    neutral300: Color(0xFFE2CED6),
    neutral400: Color(0xFFB5A6AC),
    neutral500: Color(0xFF84767C),
    neutral600: Color(0xFF67595F),
    neutral700: Color(0xFF55414A),
    neutral800: Color(0xFF3F2D35),
    text: Color(0xFF201018),
    divider: Color(0xFFE7C7D5),
    accent200: Color(0xFFD4F1D4),
    accent400: Color(0xFF79C77C),
    accent700: Color(0xFF1C6D26),
    accent900: Color(0xFF103A14),
    onAccent: Color(0xFFFFFFFF),
    sage200: Color(0xFFFFD2E7),
    sage300: Color(0xFFFFB9D9),
    sage400: Color(0xFFEE94BF),
    sage600: Color(0xFFA84E7C),
    sage900: Color(0xFF471D33),
    moods: [
      Color(0xFF1C6D26),
      Color(0xFF79C77C),
      Color(0xFFB5A6AC),
      Color(0xFFEE94BF),
      Color(0xFFA84E7C),
    ],
  );

  static const blossomDark = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF191014),
    surface: Color(0xFF25181F),
    neutral100: Color(0xFF2D1F26),
    neutral200: Color(0xFF35272E),
    neutral300: Color(0xFF403038),
    neutral400: Color(0xFF6D5561),
    neutral500: Color(0xFF876E7A),
    neutral600: Color(0xFFA38F99),
    neutral700: Color(0xFFC4B1BA),
    neutral800: Color(0xFFE0D2D9),
    text: Color(0xFFF4EBF0),
    divider: Color(0xFF3B2B33),
    accent200: Color(0xFF1C401E),
    accent400: Color(0xFF5AF263),
    accent700: Color(0xFF7BF482),
    accent900: Color(0xFFCFFCD1),
    onAccent: Color(0xFF0A290C),
    sage200: Color(0xFF381E2B),
    sage300: Color(0xFF502B3D),
    sage400: Color(0xFFC0598C),
    sage600: Color(0xFFD373A3),
    sage900: Color(0xFFF4D7E6),
    moods: [
      Color(0xFF49DF51),
      Color(0xFF5AF263),
      Color(0xFF876E7A),
      Color(0xFFC0598C),
      Color(0xFFE3ABC7),
    ],
  );

  /// Citrus: olive lime with orange.
  static const citrusLight = Palette(
    brightness: Brightness.light,
    bg: Color(0xFFF6F8EB),
    surface: Color(0xFFE7EBD1),
    neutral100: Color(0xFFFBFCF6),
    neutral200: Color(0xFFEAEDDE),
    neutral300: Color(0xFFD3D6C4),
    neutral400: Color(0xFFAAAD9E),
    neutral500: Color(0xFF7A7C6F),
    neutral600: Color(0xFF5D5F52),
    neutral700: Color(0xFF474A37),
    neutral800: Color(0xFF323523),
    text: Color(0xFF161807),
    divider: Color(0xFFD0D5B7),
    accent200: Color(0xFFFFE1C7),
    accent400: Color(0xFFED9C55),
    accent700: Color(0xFF8D4400),
    accent900: Color(0xFF4C2400),
    onAccent: Color(0xFFFFFFFF),
    sage200: Color(0xFFDFE7B9),
    sage300: Color(0xFFCFD994),
    sage400: Color(0xFFB2BD5F),
    sage600: Color(0xFF707900),
    sage900: Color(0xFF2D3100),
    moods: [
      Color(0xFF8D4400),
      Color(0xFFED9C55),
      Color(0xFFAAAD9E),
      Color(0xFFB2BD5F),
      Color(0xFF707900),
    ],
  );

  static const citrusDark = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF181910),
    surface: Color(0xFF232518),
    neutral100: Color(0xFF2C2D1F),
    neutral200: Color(0xFF343527),
    neutral300: Color(0xFF3E4030),
    neutral400: Color(0xFF6A6D55),
    neutral500: Color(0xFF84876E),
    neutral600: Color(0xFFA1A38F),
    neutral700: Color(0xFFC2C4B1),
    neutral800: Color(0xFFDEE0D2),
    text: Color(0xFFF3F4EB),
    divider: Color(0xFF393B2B),
    accent200: Color(0xFF402D1C),
    accent400: Color(0xFFF2A45A),
    accent700: Color(0xFFF4B67B),
    accent900: Color(0xFFFCE5CF),
    onAccent: Color(0xFF29190A),
    sage200: Color(0xFF36381E),
    sage300: Color(0xFF4C502B),
    sage400: Color(0xFFB5C059),
    sage600: Color(0xFFC9D373),
    sage900: Color(0xFFF1F4D7),
    moods: [
      Color(0xFFDF9249),
      Color(0xFFF2A45A),
      Color(0xFF84876E),
      Color(0xFFB5C059),
      Color(0xFFDDE3AB),
    ],
  );

  /// Peach: warm peach with teal.
  static const peachLight = Palette(
    brightness: Brightness.light,
    bg: Color(0xFFFFF3ED),
    surface: Color(0xFFFDE1D5),
    neutral100: Color(0xFFFFFAF7),
    neutral200: Color(0xFFF7E7E0),
    neutral300: Color(0xFFE3D0C7),
    neutral400: Color(0xFFB6A7A1),
    neutral500: Color(0xFF857771),
    neutral600: Color(0xFF685A54),
    neutral700: Color(0xFF56433A),
    neutral800: Color(0xFF402E26),
    text: Color(0xFF21110A),
    divider: Color(0xFFE9C9BC),
    accent200: Color(0xFFC2F3F2),
    accent400: Color(0xFF00CACB),
    accent700: Color(0xFF006F71),
    accent900: Color(0xFF003C3D),
    onAccent: Color(0xFFFFFFFF),
    sage200: Color(0xFFFFD6C1),
    sage300: Color(0xFFFFBFA0),
    sage400: Color(0xFFF49B72),
    sage600: Color(0xFFAE5528),
    sage900: Color(0xFF4A200C),
    moods: [
      Color(0xFF006F71),
      Color(0xFF00CACB),
      Color(0xFFB6A7A1),
      Color(0xFFF49B72),
      Color(0xFFAE5528),
    ],
  );

  static const peachDark = Palette(
    brightness: Brightness.dark,
    bg: Color(0xFF191310),
    surface: Color(0xFF251C18),
    neutral100: Color(0xFF2D241F),
    neutral200: Color(0xFF352B27),
    neutral300: Color(0xFF403530),
    neutral400: Color(0xFF6D5D55),
    neutral500: Color(0xFF87766E),
    neutral600: Color(0xFFA3958F),
    neutral700: Color(0xFFC4B7B1),
    neutral800: Color(0xFFE0D6D2),
    text: Color(0xFFF4EEEB),
    divider: Color(0xFF3B302B),
    accent200: Color(0xFF1C4040),
    accent400: Color(0xFF5AF2F2),
    accent700: Color(0xFF7BF4F4),
    accent900: Color(0xFFCFFCFC),
    onAccent: Color(0xFF0A2929),
    sage200: Color(0xFF38271E),
    sage300: Color(0xFF50372B),
    sage400: Color(0xFFC07A59),
    sage600: Color(0xFFD39373),
    sage900: Color(0xFFF4E1D7),
    moods: [
      Color(0xFF49DFDF),
      Color(0xFF5AF2F2),
      Color(0xFF87766E),
      Color(0xFFC07A59),
      Color(0xFFE3BDAB),
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
  sage('Organic', Palette.light, Palette.dark),
  mint('Mint', Palette.mintLight, Palette.mintDark),
  sky('Sky', Palette.skyLight, Palette.skyDark),
  blossom('Blossom', Palette.blossomLight, Palette.blossomDark),
  citrus('Citrus', Palette.citrusLight, Palette.citrusDark),
  peach('Peach', Palette.peachLight, Palette.peachDark),
  ocean('Ocean', Palette.oceanLight, Palette.oceanDark),
  desert('Desert', Palette.desertLight, Palette.desertDark),
  emerald('Emerald', Palette.emeraldLight, Palette.emeraldDark),
  rose('Rose', Palette.roseLight, Palette.roseDark),
  dusk('Dusk', Palette.duskLight, Palette.duskDark),
  slate('Slate', Palette.slateLight, Palette.slateDark),
  lavender('Lavender', Palette.lavenderLight, Palette.lavenderDark),
  sunrise('Sunrise', Palette.sunriseLight, Palette.sunriseDark),
  indigo('Indigo', Palette.indigoLight, Palette.indigoDark),
  mono('Mono', Palette.monoLight, Palette.monoDark),
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

/// Font sets for Latin text, chosen in Settings → Appearance.
enum AppFont {
  // Caprasimo is the design system's heading face (design 2026-10-26).
  classic('Classic', heading: 'Caprasimo'),
  soft('Soft serif', heading: 'Fraunces'),
  modern('Modern'),
  rounded('Rounded', heading: 'Nunito', body: 'Nunito'),
  serif('Serif', heading: 'Lora', body: 'Lora');

  const AppFont(this.label, {this.heading, this.body});
  final String label;

  /// Null means the phone's own font (Roboto on most phones).
  final String? heading;
  final String? body;

  static AppFont parse(String? s) =>
      values.firstWhere((f) => f.name == s, orElse: () => classic);
}

/// Fonts for Arabic text (ayah, hadith, quotes, tafsir).
enum ArabicFont {
  amiri('Amiri Quran', 'AmiriQuran'),
  scheherazade('Scheherazade New', 'ScheherazadeNew'),
  naskh('Noto Naskh Arabic', 'NotoNaskhArabic');

  const ArabicFont(this.label, this.family);
  final String label;
  final String family;

  static ArabicFont parse(String? s) =>
      values.firstWhere((f) => f.name == s, orElse: () => amiri);
}

/// The active fonts; swapped at the app root like [AppColors].
abstract final class AppFonts {
  static AppFont current = AppFont.classic;
  static ArabicFont arabic = ArabicFont.amiri;
}

/// Display face used for titles and section headings.
TextStyle heading(double size, {Color? color}) {
  final family = AppFonts.current.heading;
  return TextStyle(
    fontFamily: family,
    fontVariations: switch (family) {
      'Fraunces' => const [
        FontVariation('wght', 640),
        FontVariation('SOFT', 100),
      ],
      'Caprasimo' => null,
      _ => const [FontVariation('wght', 700)],
    },
    // Caprasimo has one heavy weight; asking for bold would smear it.
    fontWeight: family == 'Caprasimo' ? FontWeight.w400 : FontWeight.w700,
    fontSize: size,
    height: 1.15,
    color: color ?? AppColors.text,
  );
}

TextStyle get arabicStyle => TextStyle(
  fontFamily: AppFonts.arabic.family,
  fontSize: 22,
  height: 1.9,
  color: AppColors.neutral800,
);

TextStyle meta({Color? color, double size = 12}) =>
    TextStyle(fontSize: size, color: color ?? AppColors.neutral700);

ThemeData buildTheme(Palette p, {String? bodyFont}) {
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
    fontFamily: bodyFont,
    // Arabic names inside English text (quote and hadith sources).
    fontFamilyFallback: const ['NotoNaskhArabic'],
    brightness: p.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: p.bg,
    // Screens under More and Settings fade and slide in.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {TargetPlatform.android: FadeForwardsPageTransitionsBuilder()},
    ),
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
