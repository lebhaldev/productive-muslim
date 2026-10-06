import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/reminders.dart';
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
      onResume: () {
        final plan = ref.read(reminderPlanProvider);
        if (plan != null) {
          ref
              .read(reminderSchedulerProvider)
              .sync(plan)
              .catchError((Object _) {});
        }
      },
    );
    // Keep scheduled notifications in step with settings and habits.
    ref.listenManual<List<Reminder>?>(reminderPlanProvider, (_, plan) {
      if (plan == null || listEquals(plan, _scheduled)) return;
      _scheduled = plan;
      ref.read(reminderSchedulerProvider).sync(plan).catchError((Object _) {});
    }, fireImmediately: true);
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
    return MaterialApp.router(
      title: 'Nurday',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Palette.light),
      darkTheme: buildTheme(Palette.dark),
      themeMode: mode,
      themeAnimationDuration: Duration.zero,
      routerConfig: _router,
      builder: (context, child) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        AppColors.current = dark ? Palette.dark : Palette.light;
        // Widgets read AppColors directly, so rebuild them all on a switch.
        return KeyedSubtree(key: ValueKey(dark), child: child!);
      },
    );
  }
}
