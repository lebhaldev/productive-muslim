import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nurday/app/app.dart';
import 'package:nurday/app/theme.dart';

import '../test/helpers.dart';

/// Play Store phone screenshots (1080×2340) with icons and the real bundled
/// hadith, quotes and tafsir. The ayah comes from the API fixture (94:5), so
/// every day's ayah is pinned to that reference to keep its tafsir matching.
/// With LIVE=true (CI) the ayah is fetched from AlQuran Cloud and Quran.com
/// first; otherwise the test fixture's placeholder text shows.
/// Run: flutter test tool/store_shots_test.dart [--dart-define=LIVE=true]
const out = String.fromEnvironment('SHOTS', defaultValue: 'build/store');
const live = bool.fromEnvironment('LIVE');
const ayahUrls = [
  'https://api.alquran.cloud/v1/ayah/94:5/editions/quran-uthmani,en.sahih',
  'https://api.alquran.cloud/v1/ayah/94:5/quran-uthmani',
  'https://api.quran.com/api/v4/verses/by_key/94:5?translations=131',
];

Future<void> loadFont(String family, String path) async {
  final l = FontLoader(family)
    ..addFont(Future.value(ByteData.sublistView(File(path).readAsBytesSync())));
  await l.load();
}

String key(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

void main() {
  testWidgets('store screenshots', (tester) async {
    Directory(out).createSync(recursive: true);
    final sdk = File(Platform.resolvedExecutable).parent.parent.parent.parent;
    final mf = '${sdk.path}/artifacts/material_fonts';
    await tester.runAsync(() async {
      await loadFont('MaterialIcons', '$mf/MaterialIcons-Regular.otf');
      await loadFont('Roboto', '$mf/Roboto-Regular.ttf');
      await loadFont('Roboto', '$mf/Roboto-Medium.ttf');
      await loadFont('Fraunces', 'assets/fonts/Fraunces.ttf');
      await loadFont('AmiriQuran', 'assets/fonts/AmiriQuran.ttf');
      await loadFont('NotoNaskhArabic', 'assets/fonts/NotoNaskhArabic.ttf');
    });
    // Real responses, fetched before the app starts (tests block real HTTP).
    final fetched = <String, http.Response>{};
    if (live) {
      HttpOverrides.global = null;
      await tester.runAsync(() async {
        final c = http.Client();
        for (final u in ayahUrls) {
          // The API sometimes answers 503 for a moment: retry with backoff.
          var r = await c.get(Uri.parse(u));
          for (var wait = 2; r.statusCode != 200 && wait <= 16; wait *= 2) {
            await Future<void>.delayed(Duration(seconds: wait));
            r = await c.get(Uri.parse(u));
          }
          if (r.statusCode != 200) throw StateError('$u: ${r.statusCode}');
          fetched[u] = r;
        }
        c.close();
      });
    }
    final fixtures = fakeHttp();
    final client = MockClient(
      (req) async => fetched['${req.url}'] ?? await fixtures.get(req.url),
    );
    final db = memoryDb();
    final now = DateTime(2026, 10, 5, 7, 12);
    await tester.runAsync(() async {
      for (final kv in {
        'city': 'London',
        'placeName': 'London',
        'countryCode': 'GB',
        'lat': '51.5085',
        'lon': '-0.1257',
        // --dart-define=THEME=mint to look at another theme.
        'colorTheme': const String.fromEnvironment(
          'THEME',
          defaultValue: 'sage',
        ),
      }.entries) {
        await db.putSetting(kv.key, kv.value);
      }
      final ids = [
        await db.addHabit('Read Quran 10 min'),
        await db.addHabit('Morning adhkar'),
        await db.addHabit('Walk 20 min'),
        await db.addHabit('Call family'),
      ];
      for (var i = 1; i <= 20; i++) {
        final day = key(now.subtract(Duration(days: i)));
        for (var h = 0; h < ids.length; h++) {
          if ((i + h) % 4 != 0) await db.toggleCompletion(ids[h], day);
        }
        await db.setMood(day, (i * 7) % 5, now);
      }
      await db.toggleCompletion(ids[0], key(now));
      await db.toggleCompletion(ids[1], key(now));
      await db.setMood(key(now), 4, now);
      await db.togglePrayer(key(now), 'fajr', now);
      await db.saveJournal(
        key(now),
        'A quiet morning',
        'Prayed Fajr on time and read a page after. '
            'Grateful for a slow start before work.',
        now,
      );
    });
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.625;
    await tester.pumpWidget(
      ProviderScope(
        overrides: testOverrides(
          db,
          now,
          client: client,
          assets: (path) async => path.endsWith('ayah_refs.json')
              ? '{"refs":["94:5"]}'
              : File(path).readAsStringSync(),
        ),
        child: const RepaintBoundary(key: Key('root'), child: NurdayApp()),
      ),
    );
    Future<void> wait() async {
      for (var i = 0; i < 15; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    await wait();
    Future<void> shot(String name) async {
      await wait();
      final b = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('root')),
      );
      await tester.runAsync(() async {
        final img = await b.toImage(pixelRatio: 2.625);
        final png = await img.toByteData(format: ui.ImageByteFormat.png);
        File('$out/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
      });
    }

    void go(String path) =>
        GoRouter.of(tester.element(find.byType(Scaffold).last)).go(path);

    await shot('1-today');
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -900));
    await shot('2-ayah-hadith-quote');
    go('/habits');
    await shot('3-habits');
    go('/calendar');
    await shot('4-calendar');
    go('/journal');
    await shot('5-journal');
    go('/more/prayer');
    await shot('6-prayer');
    go('/settings/appearance');
    await shot('7-themes');
    await tester.runAsync(() => db.putSetting('colorTheme', 'night'));
    go('/today');
    await shot('8-today-night');
    await tester.pumpWidget(const SizedBox());
    await wait();
    AppColors.current = Palette.light;
  });
}
