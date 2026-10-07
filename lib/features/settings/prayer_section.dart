import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../data/prayer/prayer.dart';
import '../../widgets/common.dart';
import 'settings_widgets.dart';

class PrayerSection extends ConsumerStatefulWidget {
  const PrayerSection({super.key});

  @override
  ConsumerState<PrayerSection> createState() => _PrayerSectionState();
}

class _PrayerSectionState extends ConsumerState<PrayerSection> {
  String? _note;

  @override
  Widget build(BuildContext context) {
    final s = settingsOf(ref);
    final method = ref.watch(prayerMethodProvider);
    return NCard(
      gap: 10,
      children: [
        SettingPicker<PrayerMethod>(
          // The suggested method can change with the city.
          key: ValueKey(method),
          label: 'Calculation method',
          value: method,
          options: {for (final m in PrayerMethod.values) m: m.label},
          onChanged: (m) => ref.putSetting('prayerMethod', m.name),
        ),
        SettingPicker<AsrMadhab>(
          label: 'Asr',
          value: s.madhab,
          options: {for (final m in AsrMadhab.values) m: m.label},
          onChanged: (m) => ref.putSetting(
            'madhab',
            m == AsrMadhab.hanafi ? 'hanafi' : 'shafi',
          ),
        ),
        SettingPicker<HighLatitude>(
          label: 'High latitude rule (far north or south)',
          value: s.highLatitude,
          options: {for (final h in HighLatitude.values) h: h.label},
          onChanged: (h) => ref.putSetting('highLatitude', h.name),
        ),
        SettingSwitch(
          switchKey: const Key('prayer-alerts-switch'),
          title: 'Prayer time notifications',
          value: s.prayerAlerts,
          onChanged: (on) async {
            final note = await ref.setNotifying(
              'prayerAlerts',
              on,
              'prayer alerts',
            );
            if (mounted) setState(() => _note = note);
          },
        ),
        if (_note != null) Note(_note!, warn: true),
        const Note(
          'Times are calculated on this phone from your weather location.',
        ),
      ],
    );
  }
}
