import '../l10n/strings.dart';

/// The 5-point mood scale, stored as 0..4 (FR-4).
enum MoodLevel { rough, low, okay, good, bright }

String moodLabel(int value) => tr(MoodLevel.values[value].name);
