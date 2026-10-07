import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/common.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const _rows = [
    ('prayer', 'Prayer times', "Today's times and Qibla", Icons.access_time),
    (
      'activities',
      'Activities',
      'Log what you did, grouped by day',
      Icons.directions_walk,
    ),
    ('reflect', 'Reflect', 'Your last 30 days', Icons.insights_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return ScreenBody(
      gap: 10,
      children: [
        const ScreenTitle('More'),
        for (final (id, label, sub, icon) in _rows)
          NavRow(
            title: label,
            sub: sub,
            icon: icon,
            onTap: () => context.go('/more/$id'),
          ),
      ],
    );
  }
}

/// Title for screens under More, with a back arrow to More.
class MoreTitle extends StatelessWidget {
  const MoreTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => SubScreenTitle(
    text,
    backTooltip: 'Back to More',
    onBack: () => context.go('/more'),
  );
}
