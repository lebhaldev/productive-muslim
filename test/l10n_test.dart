import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/l10n/strings.dart';

void main() {
  final files = Directory('assets/l10n')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'));

  test('every interface language has a strings file', () {
    final codes = files.map((f) => f.uri.pathSegments.last.split('.').first);
    for (final l in AppLanguage.values) {
      if (l.code == null || l.code == 'en') continue;
      expect(codes, contains(l.code), reason: l.name);
    }
  });

  test('translations keep their placeholders and stay short labels', () {
    final ph = RegExp(r'\{\d\}');
    for (final f in files) {
      final m = (jsonDecode(f.readAsStringSync()) as Map)
          .cast<String, String>();
      expect(m, isNotEmpty, reason: f.path);
      for (final MapEntry(:key, :value) in m.entries) {
        final a = ph.allMatches(key).map((x) => x[0]).toList()..sort();
        final b = ph.allMatches(value).map((x) => x[0]).toList()..sort();
        expect(b, a, reason: '${f.path}: $key');
        // Interface copy only: never long passages (no scripture, CR-1).
        expect(value.length, lessThan(320), reason: '${f.path}: $key');
      }
    }
  });

  test('tr falls back to English and fills placeholders', () {
    AppStrings.setForTest('xx', {'Step {0} of {1}': 'Paso {0} de {1}'});
    expect(tr('Step {0} of {1}', [2, 4]), 'Paso 2 de 4');
    expect(tr('Not translated'), 'Not translated');
    AppStrings.use('en');
    expect(tr('Step {0} of {1}', [2, 4]), 'Step 2 of 4');
  });
}
