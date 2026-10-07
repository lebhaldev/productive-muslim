import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../app/providers.dart';
import '../../widgets/common.dart';
import 'settings_widgets.dart';

class LocationSection extends ConsumerStatefulWidget {
  const LocationSection({super.key});

  @override
  ConsumerState<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends ConsumerState<LocationSection> {
  late final _city = TextEditingController(text: settingsOf(ref).city);
  String? _note;

  @override
  void dispose() {
    _city.dispose();
    super.dispose();
  }

  Future<void> _saveCity() async {
    await ref.putSetting('city', _city.text.trim());
    await ref.putSetting('lat', '');
    await ref.putSetting('lon', '');
    ref.invalidate(weatherProvider);
  }

  /// Location is requested only here, on tap, and used only for weather (TR-8).
  Future<void> _useLocation() async {
    setState(() => _note = 'Finding your location…');
    try {
      var p = await Geolocator.checkPermission();
      if (p == LocationPermission.denied) {
        p = await Geolocator.requestPermission();
      }
      if (p == LocationPermission.denied ||
          p == LocationPermission.deniedForever) {
        setState(
          () => _note =
              'Location permission was not granted. Type a city instead.',
        );
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      await ref.putSetting('lat', pos.latitude.toStringAsFixed(2));
      await ref.putSetting('lon', pos.longitude.toStringAsFixed(2));
      ref.invalidate(weatherProvider);
      setState(() => _note = 'Using your location for weather.');
    } catch (_) {
      setState(() => _note = 'Location is unavailable. Type a city instead.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = settingsOf(ref);
    return NCard(
      gap: 10,
      children: [
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
        if (_note != null) Note(_note!),
        const Note(
          'Location is sent only to Open-Meteo for weather. Prayer times '
          'and Qibla are calculated on this phone from it.',
        ),
        SettingChoice<bool>(
          value: s.fahrenheit,
          options: const {false: 'Celsius', true: 'Fahrenheit'},
          onChanged: (f) => ref.putSetting('unit', f ? 'F' : 'C'),
        ),
      ],
    );
  }
}
