import 'moods.dart';

/// Fixed app copy (FR-19): written once, reviewed once, never generated.
/// Nothing here quotes or paraphrases scripture (TR-1), makes a religious
/// promise or gives mental-health advice.

/// What the mood card suggests after a mood is picked.
enum MoodSuggestion { journal, gratitude, habit }

typedef MoodReply = ({String line, MoodSuggestion suggestion});

/// One line and one suggestion per mood. Rough and low get a neutral
/// action only.
const Map<MoodLevel, MoodReply> moodReplies = {
  MoodLevel.rough: (
    line: 'Thank you for checking in.',
    suggestion: MoodSuggestion.journal,
  ),
  MoodLevel.low: (
    line: 'Thanks for noticing it.',
    suggestion: MoodSuggestion.journal,
  ),
  MoodLevel.okay: (line: 'Noted for today.', suggestion: MoodSuggestion.habit),
  MoodLevel.good: (
    line: 'Glad to hear it.',
    suggestion: MoodSuggestion.gratitude,
  ),
  MoodLevel.bright: (
    line: 'Lovely to hear.',
    suggestion: MoodSuggestion.gratitude,
  ),
};

const openJournalLabel = "Open today's journal";
const gratitudeLabel = "Write one thing you're grateful for";
String habitSuggestionLabel(String habit) => 'Mark “$habit” done';

/// Journal body placeholders, one per day in turn.
const journalPrompts = [
  'What are you grateful for today?',
  'What went well?',
  'What weighed on you?',
];

/// Weekly review card on Reflect (Fridays). Plain counts only: no scores and
/// no religious wording.
const weeklyTitle = 'Your week';
String weeklyHabits(int kept, int of) => 'Habits kept $kept of $of days';
String weeklyPrayers(int n) => 'Prayers logged $n';
String weeklyMood(String? mostly) =>
    mostly == null ? 'Mood not logged' : 'Mood mostly $mostly';
String weeklyJournal(int days) => 'Journal $days of 7 days';
const weeklyNoteLabel = 'Write a note to next week';
