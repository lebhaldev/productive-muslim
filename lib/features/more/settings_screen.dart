import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/content/quran_client.dart';
import '../../widgets/common.dart';
import 'more_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _city = TextEditingController();
  bool _cityLoaded = false;
  String? _locationNote;

  @override
  void dispose() {
    _city.dispose();
    super.dispose();
  }

  Future<void> _put(String key, String value) =>
      ref.read(databaseProvider).putSetting(key, value);

  String? _reminderNote;

  Future<void> _setDailyReminder(bool on) async {
    if (on && !await ref.read(reminderSchedulerProvider).requestPermission()) {
      setState(
        () => _reminderNote = 'Notifications are off for Nurday. Allow them in Android settings to get reminders.',
      );
      await _put('dailyReminderOn', 'false');
      return;
    }
    setState(() => _reminderNote = null);
    await _put('dailyReminderOn', '$on');
  }

  Future<void> _saveCity() async {
    await _put('city', _city.text.trim());
    await _put('lat', '');
    await _put('lon', '');
    ref.invalidate(weatherProvider);
  }

  /// Location is requested only here, on tap, and used only for weather (TR-8).
  Future<void> _useLocation() async {
    setState(() => _locationNote = 'Finding your location…');
    try {
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }
      if (p == LocationPermission.denied ||
          p == LocationPermission.deniedForever) {
        setState(
          () => _locationNote =
              'Location permission was not granted. Type a city instead.',
        );
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      await _put('lat', pos.latitude.toStringAsFixed(2));
      await _put('lon', pos.longitude.toStringAsFixed(2));
      ref.invalidate(weatherProvider);
      setState(() => _locationNote = 'Using your location for weather.');
    } catch (_) {
      setState(
        () => _locationNote = 'Location is unavailable. Type a city instead.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = settingsOf(ref);
    if (!_cityLoaded && ref.watch(settingsProvider).hasValue) {
      _city.text = s.city;
      _cityLoaded = true;
    }

    return ScreenBody(
      children: [
        const SubScreenTitle('Settings'),
        NCard(
          gap: 10,
          children: [
            const CardTitle('Weather'),
            TextField(
              controller: _city,
              decoration: const InputDecoration(labelText: 'City override'),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _saveCity(),
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
                if (_city.text.trim() != s.city) _saveCity();
              },
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _useLocation,
                icon: const Icon(Icons.my_location, size: 18),
                label: const Text('Use my location'),
              ),
            ),
            if (_locationNote != null) Text(_locationNote!, style: meta()),
            Text(
              'Location is used only for weather (Open-Meteo).',
              style: meta(),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Celsius')),
                  ButtonSegment(value: true, label: Text('Fahrenheit')),
                ],
                selected: {s.fahrenheit},
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: AppColors.sage300,
                ),
                onSelectionChanged: (v) => _put('unit', v.first ? 'F' : 'C'),
              ),
            ),
          ],
        ),
        NCard(
          gap: 10,
          children: [
            const CardTitle('Content'),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Show faith cards',
                style: TextStyle(fontSize: 15),
              ),
              value: s.showFaith,
              activeTrackColor: AppColors.sage600,
              onChanged: (v) => _put('faith', '$v'),
            ),
            DropdownButtonFormField<Translation>(
              initialValue: s.translation,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Translation'),
              items: [
                for (final t in Translation.values.where((t) => t.offered))
                  DropdownMenuItem(
                    value: t,
                    child: Text(t.label, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (t) {
                if (t != null) _put('translation', t.name);
              },
            ),
          ],
        ),
        NCard(
          children: [
            const CardTitle('Reminders'),
            Row(
              children: [
                const Expanded(
                  child: Text('Daily reminder', style: TextStyle(fontSize: 15)),
                ),
                Switch(
                  key: const Key('daily-reminder-switch'),
                  value: s.dailyReminderOn,
                  activeTrackColor: AppColors.sage600,
                  onChanged: _setDailyReminder,
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
                          if (t != null) await _put('dailyReminder', hhmm(t));
                        },
                  child: Text(s.dailyReminder),
                ),
              ],
            ),
            if (_reminderNote != null)
              Text(_reminderNote!, style: meta(color: AppColors.accent700)),
            Text('Per-habit reminders are set on each habit.', style: meta()),
          ],
        ),
        const NCard(
          gap: 6,
          color: AppColors.sage200,
          children: [
            Text(
              'Your data stays on this phone',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.sage900,
              ),
            ),
            Text(
              'Journal, mood, habits and activities are never uploaded. No account needed.',
              style: TextStyle(fontSize: 13, color: AppColors.sage900),
            ),
          ],
        ),
        const NCard(
          gap: 6,
          children: [
            CardTitle('Sources & licenses'),
            Text(
              'Quran: AlQuran Cloud (Uthmani text, Saheeh International) and Quran.com API '
              '(The Clear Quran) · Hadith: Sahih al-Bukhari, English text from the '
              'fawazahmed0/hadith-api dataset (public domain), references to sunnah.com · '
              'Weather: Open-Meteo (CC BY 4.0) · Quotes: bundled list with authors · '
              'Fonts: Amiri Quran and Fraunces (SIL Open Font License)',
              style: TextStyle(fontSize: 13, height: 1.6),
            ),
          ],
        ),
      ],
    );
  }
}
