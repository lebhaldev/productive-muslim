import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/content/quran_client.dart';
import '../../widgets/common.dart';
import 'settings_widgets.dart';

class ContentSection extends ConsumerWidget {
  const ContentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = settingsOf(ref);
    return NCard(
      gap: 10,
      children: [
        SettingSwitch(
          title: 'Show faith cards',
          value: s.showFaith,
          onChanged: (v) => ref.putSetting('faith', '$v'),
        ),
        SettingPicker<Translation>(
          label: 'Translation',
          value: s.translation,
          options: {
            for (final t in Translation.values.where((t) => t.offered))
              t: t.label,
          },
          onChanged: (t) => ref.putSetting('translation', t.name),
        ),
        SettingPicker<bool>(
          label: 'Content language',
          value: s.arabicOnly,
          options: const {false: 'Arabic + English', true: 'Arabic only'},
          onChanged: (v) =>
              ref.putSetting('contentLanguage', v ? 'ar' : 'ar_en'),
        ),
      ],
    );
  }
}
