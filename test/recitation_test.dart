import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/data/content/quran_client.dart';
import 'package:nurday/data/content/recitation.dart';

import 'helpers.dart';

void main() {
  final c = RecitationClient(fakeHttp());

  test('reciters are the Arabic verse-by-verse editions, by name', () async {
    final r = await c.reciters();
    expect(r.map((x) => x.id), ['ar.alafasy', 'ar.fixturetwo']);
    expect(r.first.englishName, 'Fixture Reciter One');
  });

  test('surah audio lists each ayah recording in order', () async {
    final a = await c.surahAudio(1, defaultReciter);
    expect(a.map((x) => x.numberInSurah), [1, 2, 3]);
    expect(a.first.url, 'https://cdn.example/fixture/1.mp3');
  });

  test('one ayah recording and the surah list', () async {
    expect(
      await c.ayahAudio('94:5', defaultReciter),
      'https://cdn.example/fixture/6126.mp3',
    );
    final s = await c.surahs();
    expect(s.first.ayahs, 3);
  });

  test('offline names the source', () async {
    final off = RecitationClient(fakeHttp(online: false));
    await expectLater(
      off.reciters(),
      throwsA(
        isA<ContentSourceException>().having(
          (e) => e.source,
          'source',
          'AlQuran Cloud',
        ),
      ),
    );
  });
}
