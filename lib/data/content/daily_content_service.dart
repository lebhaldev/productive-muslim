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
  static const hadithAsset = 'assets/content/hadith_bukhari.json';
  static const quotesAsset = 'assets/content/quotes.json';

  Future<DailyContent> load(String day, Translation translation) async {
    return DailyContent(
      ayah: await _ayah(day, translation),
      hadith: await _hadith(day),
      quote: await _quote(day),
    );
  }

  Future<ContentSlot<Ayah>> _ayah(String day, Translation t) async {
    final kind = 'ayah:${t.name}';
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
    final ref = refs[dailyIndex(day, 'ayah', refs.length)];
    try {
      final ayah = await quran.fetch(ref, t);
      final at = now();
      await db.putContent(day, kind, jsonEncode(ayah.toJson()), at);
      return ContentSlot.ok(ayah, fetchedAt: at);
    } on ContentSourceException catch (e) {
      final last = await db.latestContent(kind);
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

  Future<ContentSlot<Hadith>> _hadith(String day) async {
    try {
      final list =
          ((jsonDecode(await loadAsset(hadithAsset)) as Map)['hadiths'] as List)
              .cast<Map<String, dynamic>>();
      return ContentSlot.ok(
        Hadith.fromJson(list[dailyIndex(day, 'hadith', list.length)]),
      );
    } catch (_) {
      return const ContentSlot.failed(
        'The bundled hadith dataset could not be read.',
      );
    }
  }

  Future<ContentSlot<Quote>> _quote(String day) async {
    try {
      final list =
          ((jsonDecode(await loadAsset(quotesAsset)) as Map)['quotes'] as List)
              .cast<Map<String, dynamic>>();
      return ContentSlot.ok(
        Quote.fromJson(list[dailyIndex(day, 'quote', list.length)]),
      );
    } catch (_) {
      return const ContentSlot.failed(
        'The bundled quote list could not be read.',
      );
    }
  }
}
