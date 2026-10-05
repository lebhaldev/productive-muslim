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

  @override
  void initState() {
    super.initState();
    // Keep scheduled notifications in step with settings and habits.
    ref.listenManual<List<Reminder>?>(reminderPlanProvider, (_, plan) {
      if (plan == null || listEquals(plan, _scheduled)) return;
      _scheduled = plan;
      ref.read(reminderSchedulerProvider).sync(plan).catchError((Object _) {});
    }, fireImmediately: true);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nurday',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: _router,
    );
  }
}
