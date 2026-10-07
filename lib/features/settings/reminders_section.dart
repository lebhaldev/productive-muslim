import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../widgets/common.dart';
import 'settings_widgets.dart';

class RemindersSection extends ConsumerStatefulWidget {
  const RemindersSection({super.key});

  @override
  ConsumerState<RemindersSection> createState() => _RemindersSectionState();
}

class _RemindersSectionState extends ConsumerState<RemindersSection> {
  String? _note;

  @override
  Widget build(BuildContext context) {
    final s = settingsOf(ref);
    return NCard(
      children: [
        Row(
          children: [
            const Expanded(
              child: Text('Daily reminder', style: TextStyle(fontSize: 15)),
            ),
            Switch(
              key: const Key('daily-reminder-switch'),
              value: s.dailyReminderOn,
              activeTrackColor: AppColors.sage600,
              onChanged: (on) async {
                final note = await ref.setNotifying(
                  'dailyReminderOn',
                  on,
                  'reminders',
                );
                if (mounted) setState(() => _note = note);
              },
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: !s.dailyReminderOn
                  ? null
                  : () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: parseHhmm(s.dailyReminder),
                      );
                      if (t != null) {
                        await ref.putSetting('dailyReminder', hhmm(t));
                      }
                    },
              child: Text(s.dailyReminder),
            ),
          ],
        ),
        if (_note != null) Note(_note!, warn: true),
        const Note('Per-habit reminders are set on each habit.'),
      ],
    );
  }
}
