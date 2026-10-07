import 'dart:convert';

import 'package:flutter/services.dart';

import '../../core/content_seed.dart';
import '../db/database.dart';
import 'content_models.dart';
import 'quran_client.dart';

/// Loads bundled JSON assets. Swappable in tests to read fixtures.
typedef AssetLoader = Future<String> Function(String path);

Future<String> rootBundleLoader(String path) => rootBundle.loadString(path);

/// Picks and caches the day's ayah, hadith and quote (FR-2, TR-3).
class DailyContentService {
  DailyContentService({
    required this.db,
    required this.quran,
    required this.loadAsset,
    required this.now,
  });

  final AppDatabase db;
  final QuranClient quran;
  final AssetLoader loadAsset;
  final DateTime Function() now;

  static const ayahRefsAsset = 'assets/content/ayah_refs.json';
  static const hadithAsset = 'assets/content/hadith.json';
  static const quotesAsset = 'assets/content/quotes_ar.json';
  static const tafsirAsset = 'assets/content/tafsir.json';

  Map<String, dynamic>? _tafsir;

  /// Bundled tafsir for [ref], or null if the dataset has none for it.
  Future<Tafsir?> tafsirFor(String ref) async {
    try {
      _tafsir ??=
          jsonDecode(await loadAsset(tafsirAsset)) as Map<String, dynamic>;
      final t = _tafsir!;
      final entry = (t['ayahs'] as Map)[ref] as Map?;
      if (entry == null) return null;
      String src(String lang) {
        final m = (t['sources'] as Map)[lang] as Map;
        return '${m['name']} · ${m['author']}';
      }

      return Tafsir(
        english: entry['en'] as String,
        arabic: entry['ar'] as String,
        englishSource: src('en'),
        arabicSource: src('ar'),
      );
    } catch (_) {
      return null;
    }
  }

  /// [offsets] counts how many times the user asked for another ayah,
  /// hadith or quote today (keys `ayah`, `hadith`, `quote`).
  Future<DailyContent> load(
    String day,
    Translation translation, {
    Map<String, int> offsets = const {},
  }) async {
    return DailyContent(
      ayah: await _ayah(day, translation, offsets['ayah'] ?? 0),
      hadith: await _hadith(day, offsets['hadith'] ?? 0),
      quote: await _quote(day, offsets['quote'] ?? 0),
    );
  }

  Future<ContentSlot<Ayah>> _ayah(String day, Translation t, int offset) async {
    final base = 'ayah:${t.name}';
    final kind = offset == 0 ? base : '$base:+$offset';
    final cached = await db.cachedContent(day, kind);
    if (cached != null) {
      return ContentSlot.ok(
        _decodeAyah(cached.payload),
        fetchedAt: cached.fetchedAt,
      );
    }
    final refs =
        ((jsonDecode(await loadAsset(ayahRefsAsset)) as Map)['refs'] as List)
            .cast<String>();
    final ref = refs[contentIndex(day, 'ayah', refs.length, offset)];
    try {
      final ayah = await quran.fetch(ref, t);
      final at = now();
      await db.putContent(day, kind, jsonEncode(ayah.toJson()), at);
      return ContentSlot.ok(ayah, fetchedAt: at);
    } on ContentSourceException catch (e) {
      final last = await db.latestContent(base);
      if (last != null) {
        return ContentSlot.ok(
          _decodeAyah(last.payload),
          fetchedAt: last.fetchedAt,
          stale: true,
        );
      }
      return ContentSlot.failed(
        '${e.source} could not be reached. '
        'The ayah will appear once it loads; nothing is shown in its place.',
      );
    }
  }

  Ayah _decodeAyah(String payload) =>
      Ayah.fromJson(jsonDecode(payload) as Map<String, dynamic>);

  Future<ContentSlot<Hadith>> _hadith(String day, int offset) async {
    try {
      final list =
          ((jsonDecode(await loadAsset(hadithAsset)) as Map)['hadiths'] as List)
              .cast<Map<String, dynamic>>();
      return ContentSlot.ok(
        Hadith.fromJson(list[contentIndex(day, 'hadith', list.length, offset)]),
      );
    } catch (_) {
      return const ContentSlot.failed(
        'The bundled hadith dataset could not be read.',
      );
    }
  }

  Future<ContentSlot<Quote>> _quote(String day, int offset) async {
    try {
      final list =
          ((jsonDecode(await loadAsset(quotesAsset)) as Map)['quotes'] as List)
              .cast<Map<String, dynamic>>();
      return ContentSlot.ok(
        Quote.fromJson(list[contentIndex(day, 'quote', list.length, offset)]),
      );
    } catch (_) {
      return const ContentSlot.failed(
        'The bundled quote list could not be read.',
      );
    }
  }
}
