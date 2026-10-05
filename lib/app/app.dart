import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';
import 'theme.dart';

class NurdayApp extends StatefulWidget {
  const NurdayApp({super.key});

  @override
  State<NurdayApp> createState() => _NurdayAppState();
}

class _NurdayAppState extends State<NurdayApp> {
  final GoRouter _router = buildRouter();

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
