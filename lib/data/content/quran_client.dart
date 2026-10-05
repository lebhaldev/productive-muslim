import 'dart:convert';

import 'package:http/http.dart' as http;

import 'content_models.dart';

/// Translations offered in Settings (OQ-11).
enum Translation {
  sahih('Saheeh International'),
  khattab('Dr. Mustafa Khattab, The Clear Quran');

  const Translation(this.label);
  final String label;

  static Translation parse(String? id) => Translation.values.firstWhere(
    (t) => t.name == id,
    orElse: () => Translation.sahih,
  );
}

class ContentSourceException implements Exception {
  ContentSourceException(this.source, this.detail);
  final String source;
  final String detail;
  @override
  String toString() => '$source unavailable ($detail)';
}

/// Fetches one ayah: Uthmani Arabic from AlQuran Cloud, plus the translation
/// from AlQuran Cloud (Saheeh International) or Quran.com (The Clear Quran).
class QuranClient {
  QuranClient(this._http);
  final http.Client _http;

  static const alQuranCloud = 'AlQuran Cloud';
  static const quranCom = 'Quran.com';

  Future<Ayah> fetch(String ref, Translation t) async {
    switch (t) {
      case Translation.sahih:
        final body = await _get(
          Uri.parse(
            'https://api.alquran.cloud/v1/ayah/$ref/editions/quran-uthmani,en.sahih',
          ),
          alQuranCloud,
        );
        return parseAlQuranCloud(ref, body);
      case Translation.khattab:
        final arabic = await _get(
          Uri.parse('https://api.alquran.cloud/v1/ayah/$ref/quran-uthmani'),
          alQuranCloud,
        );
        final tr = await _get(
          Uri.parse(
            'https://api.quran.com/api/v4/verses/by_key/$ref?translations=131',
          ),
          quranCom,
        );
        return parseKhattab(ref, arabic, tr);
    }
  }

  Future<Map<String, dynamic>> _get(Uri uri, String source) async {
    final http.Response res;
    try {
      res = await _http.get(uri).timeout(const Duration(seconds: 12));
    } catch (e) {
      throw ContentSourceException(source, 'no connection');
    }
    if (res.statusCode != 200) {
      throw ContentSourceException(source, 'HTTP ${res.statusCode}');
    }
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  /// Parses `/v1/ayah/{ref}/editions/quran-uthmani,en.sahih`.
  static Ayah parseAlQuranCloud(String ref, Map<String, dynamic> body) {
    final data = (body['data'] as List).cast<Map<String, dynamic>>();
    Map<String, dynamic> byEdition(String id) =>
        data.firstWhere((d) => (d['edition'] as Map)['identifier'] == id);
    final ar = byEdition('quran-uthmani');
    final en = byEdition('en.sahih');
    return Ayah(
      ref: ref,
      surahName: (ar['surah'] as Map)['englishName'] as String,
      arabic: ar['text'] as String,
      translation: en['text'] as String,
      translator: (en['edition'] as Map)['englishName'] as String,
      edition: 'quran-uthmani + en.sahih',
      sourceUrl: 'https://quran.com/${ref.replaceAll(':', '/')}',
    );
  }

  /// Parses AlQuran Cloud `/v1/ayah/{ref}/quran-uthmani` plus Quran.com
  /// `/api/v4/verses/by_key/{ref}?translations=131`.
  static Ayah parseKhattab(
    String ref,
    Map<String, dynamic> arabicBody,
    Map<String, dynamic> trBody,
  ) {
    final ar = arabicBody['data'] as Map<String, dynamic>;
    final translations = ((trBody['verse'] as Map)['translations'] as List)
        .cast<Map<String, dynamic>>();
    final text = (translations.first['text'] as String)
        .replaceAll(RegExp(r'<sup[^>]*>.*?</sup>'), '')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .trim();
    return Ayah(
      ref: ref,
      surahName: (ar['surah'] as Map)['englishName'] as String,
      arabic: ar['text'] as String,
      translation: text,
      translator: 'Dr. Mustafa Khattab, The Clear Quran',
      edition: 'quran-uthmani + quran.com translation 131',
      sourceUrl: 'https://quran.com/${ref.replaceAll(':', '/')}',
    );
  }
}
