import 'dart:io';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/data/content/daily_content_service.dart';
import 'package:nurday/data/content/quran_client.dart';
import 'package:nurday/data/db/database.dart';
import 'package:nurday/data/weather/weather.dart';

import 'helpers.dart';

void main() {
  late AppDatabase db;
  final now = DateTime(2026, 10, 5, 7);
  setUp(() => db = memoryDb());
  tearDown(() => db.close());

  DailyContentService service({bool online = true}) => DailyContentService(
    db: db,
    quran: QuranClient(fakeHttp(online: online)),
    loadAsset: fixtureAssets,
    now: () => now,
  );

  test('ayah comes from the API response with source metadata', () async {
    final c = await service().load('2026-10-05', Translation.sahih);
    final a = c.ayah.value!;
    expect(a.arabic, '[ fixture arabic text ]');
    expect(a.translation, '[ fixture translation text ]');
    expect(a.source, 'Surah Ash-Sharh 94:5 · Saheeh International');
    expect(a.sourceUrl, 'https://quran.com/94/5');
  });

  test('The Clear Quran strips footnote markup', () async {
    final a = (await service().load(
      '2026-10-05',
      Translation.khattab,
    )).ayah.value!;
    expect(a.translation, '[ fixture clear translation ]');
    expect(a.translator, contains('Khattab'));
  });

  test('show another moves to the next item and wraps around', () async {
    final s = service();
    final first = (await s.load('2026-10-05', Translation.sahih)).quote.value!;
    final next = (await s.load(
      '2026-10-05',
      Translation.sahih,
      offsets: {'quote': 1},
    )).quote.value!;
    final again = (await s.load(
      '2026-10-05',
      Translation.sahih,
      offsets: {'quote': 2},
    )).quote.value!;
    expect(next.arabic, isNot(first.arabic));
    expect(again.arabic, first.arabic);
  });

  test('bundled tafsir is found by ayah reference', () async {
    final t = (await service().tafsirFor('94:5'))!;
    expect(t.english, '[ fixture tafsir english ]');
    expect(t.arabic, '[ fixture tafsir arabic ]');
    expect(t.arabicSource, 'Fixture Tafsir AR · Fixture Complex');
    expect(await service().tafsirFor('1:1'), isNull);
  });

  test('hadith and quote carry their citations', () async {
    final c = await service().load('2026-10-05', Translation.sahih);
    expect(c.hadith.value!.source, 'Sahih al-Bukhari · Book 2 · No. 13');
    expect(c.quote.value!.attribution, 'Fixture Author');
    expect(
      c.quote.value!.arabic,
      anyOf('[ fixture arabic quote ]', '[ second fixture quote ]'),
    );
    expect(c.quote.value!.work, 'Fixture work');
  });

  test('offline: shows the cached ayah, then names the failed source when nothing is cached', () async {
    await service().load('2026-10-04', Translation.sahih);
    final offline = await service(online: false)
        .load('2026-10-05', Translation.sahih);
    expect(offline.ayah.value, isNotNull);
    expect(offline.ayah.stale, isTrue);

    final empty = memoryDb();
    addTearDown(empty.close);
    final none = await DailyContentService(
      db: empty,
      quran: QuranClient(fakeHttp(online: false)),
      loadAsset: fixtureAssets,
      now: () => now,
    ).load('2026-10-05', Translation.sahih);
    expect(none.ayah.value, isNull);
    expect(none.ayah.error, contains('AlQuran Cloud'));
    // Bundled hadith still works offline.
    expect(none.hadith.value, isNotNull);
  });

  test('weather parses Open-Meteo and falls back to cache offline', () async {
    final fresh = await WeatherService(
      fakeHttp(),
      db,
      () => now,
    ).load(city: 'London');
    expect(fresh.weather!.place, 'London');
    expect(fresh.weather!.condition, 'Light cloud');
    expect(formatTemp(fresh.weather!.nowC, fahrenheit: false), '14°');
    expect(formatTemp(fresh.weather!.hiC, fahrenheit: true), '65°');

    final cached = await WeatherService(
      fakeHttp(online: false),
      db,
      () => now,
    ).load(city: 'London');
    expect(cached.weather!.place, 'London');
    expect(cached.fetchedAt, now);
    expect(jsonDecode((await db.cachedWeather())!.payload)['code'], 2);
  });

  test('bundled Arabic quotes are complete and cited', () {
    final data = jsonDecode(
      File('assets/content/quotes_ar.json').readAsStringSync(),
    );
    final quotes = data['quotes'] as List;
    expect(quotes.length, greaterThanOrEqualTo(40));
    for (final q in quotes) {
      expect((q['arabic'] as String).trim(), isNotEmpty, reason: q['id']);
      expect(q['author'], isNotNull, reason: q['id']);
      expect(q['work'], isNotNull, reason: q['id']);
      expect(q['sourceUrl'] as String, startsWith('https://'), reason: q['id']);
      expect(q.containsKey('english'), isFalse, reason: 'no translations');
    }
  });

  test('bundled hadith all carry Arabic', () {
    final data = jsonDecode(
      File('assets/content/hadith.json').readAsStringSync(),
    );
    for (final h in data['hadiths'] as List) {
      expect((h['arabic'] as String).trim(), isNotEmpty, reason: h['id']);
    }
  });
}
