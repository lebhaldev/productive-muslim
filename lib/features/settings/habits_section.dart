import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../widgets/common.dart';
import 'settings_widgets.dart';

class HabitsSettingsSection extends ConsumerWidget {
  const HabitsSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = settingsOf(ref);
    return NCard(
      gap: 10,
      children: [
        SettingSwitch(
          switchKey: const Key('show-consistency'),
          title: 'Show consistency numbers',
          subtitle: 'Like “4 of the last 7 days” on each habit',
          value: s.showConsistency,
          onChanged: (v) => ref.putSetting('showConsistency', '$v'),
        ),
      ],
    );
  }
}
