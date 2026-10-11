import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The privacy policy says personal data stays on the phone, so Android's
/// own cloud backup and device transfer must stay off.
void main() {
  test('the advertising ID permission is removed', () {
    final m = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(
      m,
      matches(
        RegExp(
          r'com\.google\.android\.gms\.permission\.AD_ID"\s+tools:node="remove"',
        ),
      ),
    );
  });

  test('Android cloud backup is off', () {
    final m = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(m, contains('android:allowBackup="false"'));
    expect(m, contains('android:fullBackupContent="false"'));
    expect(
      m,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );
    final rules = File('android/app/src/main/res/xml/data_extraction_rules.xml')
        .readAsStringSync();
    for (final part in ['cloud-backup', 'device-transfer']) {
      final body = rules.split('<$part>')[1].split('</$part>')[0];
      expect(body, contains('<exclude domain="database" path="." />'));
    }
  });
}
