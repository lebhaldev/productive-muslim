import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// TR-1: religious text lives only in API responses and bundled datasets,
/// never as literals in app code.
void main() {
  final sources = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart') && !f.path.endsWith('.g.dart'));

  test('no Arabic script in lib/', () {
    final arabic = RegExp(r'[؀-ۿݐ-ݿﭐ-﷿ﹰ-﻿]');
    for (final f in sources) {
      expect(arabic.hasMatch(f.readAsStringSync()), isFalse, reason: f.path);
    }
  });

  test('no bundled hadith text copied into lib/', () {
    final data = jsonDecode(
      File('assets/content/hadith_bukhari.json').readAsStringSync(),
    );
    final snippets = [
      for (final h in data['hadiths'] as List)
        // A distinctive slice from the middle of each hadith.
        (h['text'] as String).substring(
          (h['text'] as String).length ~/ 3,
          (h['text'] as String).length ~/ 3 + 30,
        ),
    ];
    for (final f in sources) {
      final code = f.readAsStringSync();
      for (final s in snippets) {
        expect(
          code.contains(s),
          isFalse,
          reason: '${f.path} contains hadith text',
        );
      }
    }
  });

  test('ayah reference list holds references only', () {
    final refs =
        jsonDecode(
              File('assets/content/ayah_refs.json').readAsStringSync(),
            )['refs']
            as List;
    for (final r in refs) {
      expect(
        RegExp(r'^\d{1,3}:\d{1,3}$').hasMatch(r as String),
        isTrue,
        reason: r,
      );
    }
  });

  test('every bundled hadith has a citation', () {
    final data = jsonDecode(
      File('assets/content/hadith_bukhari.json').readAsStringSync(),
    );
    for (final h in data['hadiths'] as List) {
      expect(h['collection'], isNotEmpty);
      expect(h['book'], isA<int>());
      expect(h['number'], isA<int>());
      expect(h['sourceUrl'], startsWith('https://sunnah.com/'));
    }
  });
}
