/// The 5-point mood scale, stored as 0..4 (FR-4).
enum MoodLevel { rough, low, okay, good, bright }

String moodLabel(int value) => MoodLevel.values[value].name;
