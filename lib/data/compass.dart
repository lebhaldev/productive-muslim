import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Heading of the phone's top edge, degrees clockwise from magnetic north,
/// from gravity [a] and the magnetic field [m] (both in device axes), the
/// same way Android's SensorManager.getRotationMatrix/getOrientation do.
/// Null when the phone is held flat on its edge or the field is unusable.
double? headingFrom(
  ({double x, double y, double z}) a,
  ({double x, double y, double z}) m,
) {
  // H = m × a points east; M = a × H points north (magnetic).
  var hx = m.y * a.z - m.z * a.y;
  var hy = m.z * a.x - m.x * a.z;
  var hz = m.x * a.y - m.y * a.x;
  final normH = math.sqrt(hx * hx + hy * hy + hz * hz);
  if (normH < 0.1) return null;
  hx /= normH;
  hy /= normH;
  hz /= normH;
  final normA = math.sqrt(a.x * a.x + a.y * a.y + a.z * a.z);
  if (normA == 0) return null;
  final ax = a.x / normA, az = a.z / normA;
  final my = az * hx - ax * hz;
  final deg = math.atan2(hy, my) * 180 / math.pi;
  return (deg + 360) % 360;
}

/// Smallest signed angle from [from] to [to], −180…180.
double angleDiff(double from, double to) => ((to - from + 540) % 360) - 180;

/// Live heading in degrees from magnetic north; faked in tests.
abstract interface class Compass {
  Stream<double> headings();

  /// Degrees to add to a magnetic heading to get true north at a place
  /// (Android's built-in geomagnetic model); 0 if unknown.
  Future<double> declination(double lat, double lon);
}

class SensorCompass implements Compass {
  static const _channel = MethodChannel('nurday/geomag');

  @override
  Stream<double> headings() {
    ({double x, double y, double z})? a;
    double? smooth;
    final out = StreamController<double>();
    final subs = <StreamSubscription<Object>>[];
    out.onListen = () {
      subs.add(
        accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval)
            .listen((e) => a = (x: e.x, y: e.y, z: e.z)),
      );
      subs.add(
        magnetometerEventStream(samplingPeriod: SensorInterval.uiInterval)
            .listen((e) {
              final g = a;
              if (g == null) return;
              final h = headingFrom(g, (x: e.x, y: e.y, z: e.z));
              if (h == null) return;
              // Low-pass on the circle so the needle does not jitter.
              smooth = smooth == null
                  ? h
                  : (smooth! + angleDiff(smooth!, h) * 0.2) % 360;
              out.add((smooth! + 360) % 360);
            }, onError: out.addError),
      );
    };
    out.onCancel = () async {
      for (final s in subs) {
        await s.cancel();
      }
    };
    return out.stream;
  }

  @override
  Future<double> declination(double lat, double lon) async {
    try {
      final d = await _channel.invokeMethod<double>('declination', {
        'lat': lat,
        'lon': lon,
      });
      return d ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
