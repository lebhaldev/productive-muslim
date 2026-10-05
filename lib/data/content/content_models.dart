/// Daily content items. Religious text in these objects always comes from an
/// API response or a bundled dataset, never from app code (TR-1).
library;

class Ayah {
  const Ayah({
    required this.ref,
    required this.surahName,
    required this.arabic,
    required this.translation,
    required this.translator,
    required this.edition,
    required this.sourceUrl,
  });

  final String ref; // e.g. 94:5
  final String surahName; // e.g. Ash-Sharh
  final String arabic;
  final String translation;
  final String translator;
  final String edition; // e.g. quran-uthmani + en.sahih
  final String sourceUrl;

  String get source => 'Surah $surahName $ref · $translator';

  Map<String, dynamic> toJson() => {
    'ref': ref,
    'surahName': surahName,
    'arabic': arabic,
    'translation': translation,
    'translator': translator,
    'edition': edition,
    'sourceUrl': sourceUrl,
  };

  factory Ayah.fromJson(Map<String, dynamic> j) => Ayah(
    ref: j['ref'] as String,
    surahName: j['surahName'] as String,
    arabic: j['arabic'] as String,
    translation: j['translation'] as String,
    translator: j['translator'] as String,
    edition: j['edition'] as String,
    sourceUrl: j['sourceUrl'] as String,
  );
}

class Hadith {
  const Hadith({
    required this.collection,
    required this.book,
    required this.bookName,
    required this.number,
    required this.text,
    required this.grade,
    required this.sourceUrl,
  });

  final String collection;
  final int book;
  final String bookName;
  final int number;
  final String text;
  final String grade;
  final String sourceUrl;

  String get source => '$collection · Book $book · No. $number';

  factory Hadith.fromJson(Map<String, dynamic> j) => Hadith(
    collection: j['collection'] as String,
    book: j['book'] as int,
    bookName: j['bookName'] as String,
    number: j['number'] as int,
    text: j['text'] as String,
    grade: j['grade'] as String,
    sourceUrl: j['sourceUrl'] as String,
  );
}

class Quote {
  const Quote({required this.text, required this.author, required this.source});

  final String text;
  final String? author;
  final String source;

  String get attribution => author ?? 'Unknown';

  factory Quote.fromJson(Map<String, dynamic> j) => Quote(
    text: j['text'] as String,
    author: j['author'] as String?,
    source: j['source'] as String,
  );
}

/// A content slot on Today: the item, when it was fetched, or why it failed.
class ContentSlot<T> {
  const ContentSlot.ok(T this.value, {this.fetchedAt, this.stale = false})
    : error = null;
  const ContentSlot.failed(String this.error)
    : value = null,
      fetchedAt = null,
      stale = false;

  final T? value;
  final DateTime? fetchedAt;

  /// True when showing an earlier day's cached item because the fetch failed.
  final bool stale;
  final String? error;
}

class DailyContent {
  const DailyContent({
    required this.ayah,
    required this.hadith,
    required this.quote,
  });
  final ContentSlot<Ayah> ayah;
  final ContentSlot<Hadith> hadith;
  final ContentSlot<Quote> quote;
}
