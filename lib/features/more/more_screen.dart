import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../../widgets/common.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const _rows = [
    ('prayer', 'Prayer times', "Today's times and Qibla"),
    ('activities', 'Activities', 'Log what you did, grouped by day'),
    ('reflect', 'Reflect', 'Your last 30 days'),
    ('settings', 'Settings', 'Weather, prayer, reminders, theme, privacy'),
  ];

  @override
  Widget build(BuildContext context) {
    return ScreenBody(
      gap: 10,
      children: [
        const ScreenTitle('More'),
        for (final (id, label, sub) in _rows)
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.lg),
              onTap: () => context.go('/more/$id'),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: heading(18)),
                    const SizedBox(height: 2),
                    Text(sub, style: meta(size: 13)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Header with a back arrow for screens under More.
class SubScreenTitle extends StatelessWidget {
  const SubScreenTitle(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        tooltip: 'Back to More',
        onPressed: () => context.go('/more'),
        icon: const Icon(Icons.arrow_back),
      ),
      const SizedBox(width: 4),
      Expanded(child: ScreenTitle(text)),
    ],
  );
}
