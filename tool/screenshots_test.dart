import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/app/app.dart';

import '../test/helpers.dart';

/// Renders key screens to PNGs so layout can be checked without a phone.
/// Run: flutter test tool/screenshots_test.dart [--dart-define=SHOTS=dir]
/// Icons show as boxes (no icon font in tests); text uses the app fonts.
const out = String.fromEnvironment('SHOTS', defaultValue: 'build/screenshots');

Future<void> loadFont(String family, String path) async {
  final l = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
  await l.load();
}

void main() {
  testWidgets('screenshots', (tester) async {
    Directory(out).createSync(recursive: true);
    await tester.runAsync(() async {
      await loadFont('Fraunces', 'assets/fonts/Fraunces.ttf');
      await loadFont('AmiriQuran', 'assets/fonts/AmiriQuran.ttf');
      await loadFont('ScheherazadeNew', 'assets/fonts/ScheherazadeNew.ttf');
      await loadFont('NotoNaskhArabic', 'assets/fonts/NotoNaskhArabic.ttf');
      await loadFont('Nunito', 'assets/fonts/Nunito.ttf');
      await loadFont('Lora', 'assets/fonts/Lora.ttf');
      final roboto = Directory('/usr/share/fonts')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('DejaVuSans.ttf'));
      if (roboto.isNotEmpty) await loadFont('Roboto', roboto.first.path);
    });
    final db = memoryDb();
    final now = DateTime(2026, 10, 5, 7, 12);
    await tester.runAsync(() async {
      await db.putSetting('city', 'London');
      await db.addHabit('Read Quran 10 min');
      await db.addHabit('Morning walk');
      await db.addHabit('Dhikr after Fajr');
    });
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(db, now),
        child: const RepaintBoundary(key: Key('root'), child: NurdayApp()),
      ),
    );
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    Future<void> shot(String name) async {
      final b = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('root')),
      );
      await tester.runAsync(() async {
        final img = await b.toImage(pixelRatio: 1.2);
        final png = await img.toByteData(format: ui.ImageByteFormat.png);
        File('$out/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
      });
    }

    await shot('today-top');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await shot('today-bottom');
    await tester.tap(find.byKey(const Key('tab-Today')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 1200));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('open-settings')));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await shot('settings');
    await tester.tap(find.byKey(const Key('settings-appearance')));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await shot('appearance');
    await tester.pumpWidget(const SizedBox());
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    // Leave the in-memory database open: closing it inside a screenshot run
    // can hang the test.
  });
}
