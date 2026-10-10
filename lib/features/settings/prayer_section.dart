import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
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

  /// Whether Android lets Nurday fire alerts at the exact minute; null until
  /// checked.
  bool? _exact;
  late final AppLifecycleListener _life;

  @override
  void initState() {
    super.initState();
    _checkExact();
    // The "Alarms & reminders" page is a separate Android screen; re-check
    // when the user comes back from it.
    _life = AppLifecycleListener(onResume: _checkExact);
  }

  @override
  void dispose() {
    _life.dispose();
    super.dispose();
  }

  Future<void> _checkExact() async {
    final ok = await ref.read(reminderSchedulerProvider).canExact();
    if (mounted) setState(() => _exact = ok);
  }

  Future<void> _adjust(PrayerName p, int by) async {
    final m = (settingsOf(ref).prayerAdjust(p) + by).clamp(-30, 30);
    await ref.putSetting('adjust_${p.name}', '$m');
  }

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
        if (s.prayerAlerts && _exact == false) ...[
          const Note(
            'Android may delay alerts by a few minutes. '
            'Allow "Alarms & reminders" for alerts on the exact minute.',
            warn: true,
          ),
          OutlinedButton(
            key: const Key('allow-exact'),
            onPressed: () async {
              await ref.read(reminderSchedulerProvider).requestExact();
              await _checkExact();
            },
            child: const Text('Allow on-time alerts'),
          ),
        ],
        if (s.prayerAlerts)
          OutlinedButton(
            key: const Key('test-notification'),
            onPressed: () async {
              await ref.read(reminderSchedulerProvider).test();
              if (mounted) {
                setState(() => _note = 'Test notification sent.');
              }
            },
            child: const Text('Send a test notification'),
          ),
        SettingPicker<int>(
          key: const Key('hijri-offset'),
          label: 'Hijri date',
          value: s.hijriOffset,
          options: const {
            -2: '2 days earlier',
            -1: '1 day earlier',
            0: 'As calculated',
            1: '1 day later',
            2: '2 days later',
          },
          onChanged: (d) => ref.putSetting('hijriOffset', '$d'),
        ),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            key: const Key('prayer-adjust'),
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            title: Text('Adjust times to match your mosque'),
            children: [
              for (final p in PrayerName.values)
                _AdjustRow(
                  name: p,
                  minutes: s.prayerAdjust(p),
                  onChange: (by) => _adjust(p, by),
                ),
            ],
          ),
        ),
        const Note(
          'Times are calculated on this phone from your weather location.',
        ),
      ],
    );
  }
}

class _AdjustRow extends StatelessWidget {
  const _AdjustRow({
    required this.name,
    required this.minutes,
    required this.onChange,
  });
  final PrayerName name;
  final int minutes;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) {
    final shown = minutes == 0
        ? 'On time'
        : '${minutes > 0 ? '+' : '−'}${minutes.abs()} min';
    return Row(
      children: [
        Expanded(child: Text(prayerLabels[name]!)),
        RoundIconButton(
          key: Key('adjust-minus-${name.name}'),
          icon: Icons.remove,
          label: '${prayerLabels[name]} one minute earlier',
          onPressed: minutes <= -30 ? null : () => onChange(-1),
        ),
        SizedBox(
          width: 72,
          child: Text(
            shown,
            key: Key('adjust-value-${name.name}'),
            textAlign: TextAlign.center,
            style: meta(),
          ),
        ),
        RoundIconButton(
          key: Key('adjust-plus-${name.name}'),
          icon: Icons.add,
          label: '${prayerLabels[name]} one minute later',
          onPressed: minutes >= 30 ? null : () => onChange(1),
        ),
      ],
    );
  }
}
