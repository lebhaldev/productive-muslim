import 'dart:convert';

import 'package:http/http.dart' as http;

import '../db/database.dart';

/// Weather snapshot, stored in Celsius and converted for display.
class Weather {
  const Weather({
    required this.nowC,
    required this.hiC,
    required this.loC,
    required this.code,
    required this.place,
    this.lat,
    this.lon,
    this.countryCode,
  });

  final double nowC;
  final double hiC;
  final double loC;
  final int code;
  final String place;

  /// Where the forecast is for; also used for prayer times and Qibla.
  final double? lat;
  final double? lon;

  /// ISO country code from geocoding, used to suggest a prayer method.
  final String? countryCode;

  String get condition => conditionLabel(code);

  Map<String, dynamic> toJson() => {
    'nowC': nowC,
    'hiC': hiC,
    'loC': loC,
    'code': code,
    'place': place,
    'lat': lat,
    'lon': lon,
    'countryCode': countryCode,
  };

  factory Weather.fromJson(Map<String, dynamic> j) => Weather(
    nowC: (j['nowC'] as num).toDouble(),
    hiC: (j['hiC'] as num).toDouble(),
    loC: (j['loC'] as num).toDouble(),
    code: j['code'] as int,
    place: j['place'] as String,
    lat: (j['lat'] as num?)?.toDouble(),
    lon: (j['lon'] as num?)?.toDouble(),
    countryCode: j['countryCode'] as String?,
  );
}

/// WMO weather codes as used by Open-Meteo.
String conditionLabel(int code) {
  if (code == 0) return 'Clear';
  if (code <= 2) return 'Light cloud';
  if (code == 3) return 'Overcast';
  if (code <= 48) return 'Fog';
  if (code <= 57) return 'Drizzle';
  if (code <= 67) return 'Rain';
  if (code <= 77) return 'Snow';
  if (code <= 82) return 'Showers';
  if (code <= 86) return 'Snow showers';
  return 'Thunderstorm';
}

String formatTemp(double c, {required bool fahrenheit}) =>
    '${(fahrenheit ? c * 9 / 5 + 32 : c).round()}°';

class WeatherState {
  const WeatherState({this.weather, this.fetchedAt, this.error});
  final Weather? weather;
  final DateTime? fetchedAt;
  final String? error;
}

/// Open-Meteo forecast and geocoding (no key). Location is only sent here (TR-8).
class WeatherService {
  WeatherService(this._http, this.db, this.now);
  final http.Client _http;
  final AppDatabase db;
  final DateTime Function() now;

  /// Returns fresh weather when online, otherwise the last cached snapshot.
  Future<WeatherState> load({String? city, double? lat, double? lon}) async {
    try {
      double la, lo;
      String place;
      String? country;
      if (lat != null && lon != null) {
        la = lat;
        lo = lon;
        place = 'My location';
      } else if (city != null && city.trim().isNotEmpty) {
        final geo = await _get(
          Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
            'name': city.trim(),
            'count': '1',
          }),
        );
        final results = (geo['results'] as List?) ?? const [];
        if (results.isEmpty) {
          return WeatherState(error: 'City "$city" not found');
        }
        final r = results.first as Map<String, dynamic>;
        la = (r['latitude'] as num).toDouble();
        lo = (r['longitude'] as num).toDouble();
        place = r['name'] as String;
        country = r['country_code'] as String?;
      } else {
        return await _cachedOr('Set a city in Settings');
      }
      final body = await _get(
        Uri.https('api.open-meteo.com', '/v1/forecast', {
          'latitude': '$la',
          'longitude': '$lo',
          'current': 'temperature_2m,weather_code',
          'daily': 'temperature_2m_max,temperature_2m_min',
          'timezone': 'auto',
          'forecast_days': '1',
        }),
      );
      final w = parseForecast(
        body,
        place,
        lat: la,
        lon: lo,
        countryCode: country,
      );
      final at = now();
      await db.putWeather(place, jsonEncode(w.toJson()), at);
      return WeatherState(weather: w, fetchedAt: at);
    } catch (_) {
      return _cachedOr('Open-Meteo could not be reached');
    }
  }

  Future<WeatherState> _cachedOr(String error) async {
    final c = await db.cachedWeather();
    if (c == null) return WeatherState(error: error);
    return WeatherState(
      weather: Weather.fromJson(jsonDecode(c.payload) as Map<String, dynamic>),
      fetchedAt: c.fetchedAt,
    );
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final res = await _http.get(uri).timeout(const Duration(seconds: 12));
    if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  static Weather parseForecast(
    Map<String, dynamic> body,
    String place, {
    double? lat,
    double? lon,
    String? countryCode,
  }) {
    final current = body['current'] as Map<String, dynamic>;
    final daily = body['daily'] as Map<String, dynamic>;
    return Weather(
      nowC: (current['temperature_2m'] as num).toDouble(),
      hiC: ((daily['temperature_2m_max'] as List).first as num).toDouble(),
      loC: ((daily['temperature_2m_min'] as List).first as num).toDouble(),
      code: current['weather_code'] as int,
      place: place,
      lat: lat,
      lon: lon,
      countryCode: countryCode,
    );
  }
}
