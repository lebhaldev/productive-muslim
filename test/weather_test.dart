import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nurday/data/weather/weather.dart';
import 'package:nurday/widgets/weather_icon.dart';

void main() {
  test('Open-Meteo codes map to the design icon groups', () {
    expect(weatherKind(0), WeatherKind.clear);
    expect(weatherKind(2), WeatherKind.partlyCloudy);
    expect(weatherKind(3), WeatherKind.cloudy);
    expect(weatherKind(48), WeatherKind.fog);
    expect(weatherKind(61), WeatherKind.rain);
    expect(weatherKind(81), WeatherKind.rain);
    expect(weatherKind(75), WeatherKind.snow);
    expect(weatherKind(86), WeatherKind.snow);
    expect(weatherKind(96), WeatherKind.thunder);
    expect(weatherKind(1, windKmh: 45), WeatherKind.windy);
    expect(weatherKind(63, windKmh: 45), WeatherKind.rain, reason: 'wet wins');
  });

  test('wind speed is read from the forecast and survives the cache', () {
    final w = WeatherService.parseForecast({
      'current': {
        'temperature_2m': 14.2,
        'weather_code': 1,
        'wind_speed_10m': 12.5,
      },
      'daily': {
        'temperature_2m_max': [18.0],
        'temperature_2m_min': [9.0],
      },
    }, 'London');
    expect(w.windKmh, 12.5);
    expect(Weather.fromJson(w.toJson()).windKmh, 12.5);
  });

  testWidgets('weather icons hold still with reduce motion', (tester) async {
    for (final kind in WeatherKind.values) {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Center(child: WeatherIcon(kind: kind)),
        ),
      );
      expect(tester.hasRunningAnimations, isFalse, reason: kind.name);
    }
    await tester.pumpWidget(Center(child: WeatherIcon(kind: WeatherKind.rain)));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpWidget(const SizedBox());
  });
}
