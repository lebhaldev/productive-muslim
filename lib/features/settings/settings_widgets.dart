import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';

extension SettingsWrite on WidgetRef {
  /// Saves one setting; every screen watching settings updates.
  Future<void> putSetting(String key, String value) =>
      read(databaseProvider).putSetting(key, value);

  /// Turns a notification setting on or off. Turning it on asks Android for
  /// permission first; if refused, the setting stays off and the returned
  /// note says why ([what] e.g. "reminders").
  Future<String?> setNotifying(String key, bool on, String what) async {
    if (on && !await read(reminderSchedulerProvider).requestPermission()) {
      await putSetting(key, 'false');
      return 'Notifications are off for Nurday. '
          'Allow them in Android settings to get $what.';
    }
    await putSetting(key, '$on');
    return null;
  }
}

/// A switch row in a settings card.
class SettingSwitch extends StatelessWidget {
  const SettingSwitch({
    super.key,
    this.switchKey,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  /// Key for the switch itself, so tests can read its value.
  final Key? switchKey;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    key: switchKey,
    contentPadding: EdgeInsets.zero,
    title: Text(title, style: const TextStyle(fontSize: 15)),
    subtitle: subtitle == null ? null : Text(subtitle!, style: meta()),
    value: value,
    activeTrackColor: AppColors.sage600,
    onChanged: onChanged,
  );
}

/// A dropdown with a label, from value → label pairs.
class SettingPicker<T> extends StatelessWidget {
  const SettingPicker({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String label;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    initialValue: value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: [
      for (final e in options.entries)
        DropdownMenuItem(
          value: e.key,
          child: Text(e.value, overflow: TextOverflow.ellipsis),
        ),
    ],
    onChanged: (v) {
      if (v != null) onChanged(v);
    },
  );
}

/// A row of segments for a small fixed choice (units, light/dark).
class SettingChoice<T> extends StatelessWidget {
  const SettingChoice({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final T value;
  final Map<T, String> options;

  /// Null disables the control.
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: SegmentedButton<T>(
      segments: [
        for (final e in options.entries)
          ButtonSegment(value: e.key, label: Text(e.value)),
      ],
      selected: {value},
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: AppColors.sage300,
      ),
      onSelectionChanged: onChanged == null ? null : (v) => onChanged!(v.first),
    ),
  );
}
