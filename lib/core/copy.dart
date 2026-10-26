import 'moods.dart';

/// Fixed app copy (FR-19): written once, reviewed once, never generated.
/// Nothing here quotes or paraphrases scripture (TR-1), makes a religious
/// promise or gives mental-health advice.

/// What the mood card suggests after a mood is picked. [walk] is advice only:
/// its button just closes the reply.
enum MoodSuggestion { walk, journal, smallThing, gratitude, goodThing }

typedef MoodReply = ({String line, MoodSuggestion suggestion});

/// One line and one suggestion per mood (design 2026-10-26, section 1).
const Map<MoodLevel, MoodReply> moodReplies = {
  MoodLevel.rough: (
    line: 'That sounds heavy. Go gently today.',
    suggestion: MoodSuggestion.walk,
  ),
  MoodLevel.low: (
    line: 'Thanks for noticing it.',
    suggestion: MoodSuggestion.journal,
  ),
  MoodLevel.okay: (
    line: 'An ordinary day is fine.',
    suggestion: MoodSuggestion.smallThing,
  ),
  MoodLevel.good: (
    line: 'Glad to hear it.',
    suggestion: MoodSuggestion.gratitude,
  ),
  MoodLevel.bright: (
    line: 'Lovely. Hold on to it.',
    suggestion: MoodSuggestion.goodThing,
  ),
};

const moodSuggestionLabels = {
  MoodSuggestion.walk: 'Take a slow walk',
  MoodSuggestion.journal: "Open today's journal",
  MoodSuggestion.smallThing: 'Log one small thing you did',
  MoodSuggestion.gratitude: "Write one thing you're grateful for",
  MoodSuggestion.goodThing: 'Note what made today good',
};

String moodSaved(String mood) =>
    'Saved · $mood. The suggestion stays away until tomorrow or until the '
    'mood changes.';

/// Journal body placeholders, one per day in turn.
const journalPrompts = [
  'What are you grateful for today?',
  'What went well?',
  'What weighed on you?',
];

/// Weekly review card on Reflect (from Friday until Thursday night). Plain
/// counts only: no scores and no religious wording.
const weeklyTitle = 'Your week';
const weeklyHabitsLabel = 'Habits kept';
String weeklyDays(int n, int of) => '$n of $of days';
const weeklyPrayersLabel = 'Prayers logged';
const weeklyMoodLabel = 'Mood';
String weeklyMood(String? mostly) =>
    mostly == null ? 'not logged' : 'mostly $mostly';
const weeklyJournalLabel = 'Journal';
const weeklyNoteLabel = 'Write a note to next week';
