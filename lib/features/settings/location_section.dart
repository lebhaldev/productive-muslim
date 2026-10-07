import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../data/weather/weather.dart';
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
  Timer? _debounce;
  List<CityOption> _suggestions = const [];
  String _lastQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _city.dispose();
    super.dispose();
  }

  Future<void> _setPlace({
    required String city,
    String lat = '',
    String lon = '',
    String placeName = '',
    String countryCode = '',
  }) async {
    await ref.putSetting('city', city);
    await ref.putSetting('lat', lat);
    await ref.putSetting('lon', lon);
    await ref.putSetting('placeName', placeName);
    await ref.putSetting('countryCode', countryCode);
    ref.invalidate(weatherProvider);
  }

  /// Typed text without picking a suggestion: geocoded when weather loads.
  Future<void> _saveTyped() => _setPlace(city: _city.text.trim());

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(text));
  }

  Future<void> _search(String text) async {
    _lastQuery = text;
    try {
      final found = await ref.read(weatherServiceProvider).searchCities(text);
      if (!mounted || text != _lastQuery) return;
      setState(() => _suggestions = found);
    } catch (_) {
      if (mounted) setState(() => _suggestions = const []);
    }
  }

  Future<void> _pick(CityOption c) async {
    FocusScope.of(context).unfocus();
    _debounce?.cancel();
    _city.text = c.name;
    setState(() {
      _suggestions = const [];
      _note = 'Using ${c.label}.';
    });
    await _setPlace(
      city: c.name,
      lat: c.lat.toStringAsFixed(4),
      lon: c.lon.toStringAsFixed(4),
      placeName: c.name,
      countryCode: c.countryCode ?? '',
    );
  }

  /// Location is requested only here, on tap (TR-8).
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
              'Location permission was not granted. Search for a city instead.',
        );
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      );
      ({String? name, String? countryCode}) place = (
        name: null,
        countryCode: null,
      );
      try {
        place = await ref.read(reverseGeocoderProvider)(
          pos.latitude,
          pos.longitude,
        );
      } catch (_) {
        // No geocoder on this phone: weather still works, unnamed.
      }
      _city.text = place.name ?? '';
      await _setPlace(
        city: place.name ?? '',
        lat: pos.latitude.toStringAsFixed(2),
        lon: pos.longitude.toStringAsFixed(2),
        placeName: place.name ?? '',
        countryCode: place.countryCode ?? '',
      );
      setState(
        () => _note = place.name == null
            ? 'Using your location. The phone could not name the place.'
            : 'Using your location: ${place.name}.',
      );
    } catch (_) {
      setState(
        () => _note = 'Location is unavailable. Search for a city instead.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = settingsOf(ref);
    final current = s.placeName ?? (s.city.isEmpty ? null : s.city);
    return NCard(
      gap: 10,
      children: [
        if (current != null)
          Text('Current place: $current', style: meta(size: 13)),
        TextField(
          key: const Key('city-search'),
          controller: _city,
          decoration: const InputDecoration(
            labelText: 'Search for a city',
            prefixIcon: Icon(Icons.search),
          ),
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: (_) {
            if (_suggestions.isNotEmpty) {
              _pick(_suggestions.first);
            } else {
              _saveTyped();
            }
          },
        ),
        if (_suggestions.isNotEmpty)
          Material(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(AppRadii.md),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (final c in _suggestions)
                  ListTile(
                    key: Key('city-option-${c.name}-${c.lat}'),
                    dense: true,
                    leading: Icon(
                      Icons.place_outlined,
                      color: AppColors.neutral700,
                    ),
                    title: Text(c.name),
                    subtitle: Text(
                      [?c.region, ?c.country].join(', '),
                      style: meta(),
                    ),
                    onTap: () => _pick(c),
                  ),
              ],
            ),
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
          'City search and weather use Open-Meteo. "Use my location" asks '
          "your phone's built-in geocoder for the place name. Prayer times "
          'and Qibla are calculated on this phone.',
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
