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
