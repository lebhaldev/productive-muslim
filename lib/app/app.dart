import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' show Intl;

import '../data/reminders.dart';
import '../l10n/app_localizations.dart';
import '../l10n/strings.dart';
import '../widgets/motion.dart';
import 'providers.dart';
import 'router.dart';
import 'theme.dart';

class NurdayApp extends ConsumerStatefulWidget {
  const NurdayApp({super.key});

  @override
  ConsumerState<NurdayApp> createState() => _NurdayAppState();
}

class _NurdayAppState extends ConsumerState<NurdayApp> {
  final GoRouter _router = buildRouter();
  List<Reminder>? _scheduled;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // On resume, reschedule in case the time zone changed while away.
    _lifecycle = AppLifecycleListener(
      // Lock the journal again whenever Nurday leaves the screen.
      onHide: () => ref.read(journalUnlockedProvider.notifier).set(false),
      onResume: () {
        _backUpIfDue();
        final plan = ref.read(reminderPlanProvider);
        if (plan != null) {
          ref
              .read(reminderSchedulerProvider)
              .sync(plan)
              .catchError((Object _) {});
        }
      },
    );
    // Daily Drive backup, once settings have loaded.
    ref.listenManual(settingsProvider, (prev, next) {
      if (prev?.hasValue != true && next.hasValue) _backUpIfDue();
    }, fireImmediately: true);
    // Keep the next-prayer home-screen widget's times current.
    ref.listenManual<Map<String, String>>(homeWidgetDataProvider, (prev, next) {
      if (mapEquals(prev, next)) return;
      ref.read(homeWidgetProvider).write(next).catchError((Object _) {});
    }, fireImmediately: true);
    // Keep scheduled notifications in step with settings and habits.
    ref.listenManual<List<Reminder>?>(reminderPlanProvider, (_, plan) {
      if (plan == null || listEquals(plan, _scheduled)) return;
      _scheduled = plan;
      ref.read(reminderSchedulerProvider).sync(plan).catchError((Object _) {});
    }, fireImmediately: true);
  }

  void _backUpIfDue() {
    final s = ref.read(settingsProvider).value;
    if (s != null) ref.read(driveSyncProvider).backUpIfDue(s.raw);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(
      settingsProvider.select((s) => s.value?.themeMode ?? ThemeMode.system),
    );
    final colors = ref.watch(
      settingsProvider.select(
        (s) => s.value?.colorTheme ?? ColorTheme.fallback,
      ),
    );
    final font = ref.watch(
      settingsProvider.select((s) => s.value?.appFont ?? AppFont.classic),
    );
    final arabic = ref.watch(
      settingsProvider.select((s) => s.value?.arabicFont ?? ArabicFont.amiri),
    );
    final motionPref = ref.watch(
      settingsProvider.select((s) => MotionPref.parse(s.value?.raw['motion'])),
    );
    final language = ref.watch(
      settingsProvider.select((s) => s.value?.language ?? AppLanguage.system),
    );
    return MaterialApp.router(
      title: 'Nurday',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: language.code == null ? null : Locale(language.code!),
      // Also called with the picked locale. "System" uses the phone's
      // language only once a native speaker has reviewed it (FR-21).
      localeResolutionCallback: (device, supported) => Locale(
        language.code ??
            (reviewedLanguages.contains(device?.languageCode)
                ? device!.languageCode
                : 'en'),
      ),
      debugShowCheckedModeBanner: false,
      theme: buildTheme(colors.light, bodyFont: font.body),
      darkTheme: buildTheme(colors.dark, bodyFont: font.body),
      themeMode: colors.alwaysDark ? ThemeMode.dark : mode,
      themeAnimationDuration: Duration.zero,
      routerConfig: _router,
      builder: (context, child) {
        final palette = colors.paletteFor(Theme.of(context).brightness);
        AppColors.current = palette;
        AppFonts.current = font;
        AppFonts.arabic = arabic;
        MotionPref.current = motionPref;
        final lang = Localizations.localeOf(context).languageCode;
        if (AppStrings.code != lang) {
          AppStrings.use(lang);
          Intl.defaultLocale = lang;
        }
        // Widgets read AppColors and AppFonts directly, so rebuild them all
        // on a switch.
        return KeyedSubtree(
          key: ValueKey((palette, font, arabic, lang, motionPref)),
          child: child!,
        );
      },
    );
  }
}
