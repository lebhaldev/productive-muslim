import 'dart:convert';

import 'package:home_widget/home_widget.dart';

/// Writes what the home-screen widget shows; faked in tests.
abstract interface class HomeWidgetSink {
  Future<void> write(Map<String, String> data);
}

class AndroidHomeWidget implements HomeWidgetSink {
  static const _name = 'com.nurday.app.NextPrayerWidget';

  @override
  Future<void> write(Map<String, String> data) async {
    try {
      for (final e in data.entries) {
        await HomeWidget.saveWidgetData<String>(e.key, e.value);
      }
      await HomeWidget.updateWidget(qualifiedAndroidName: _name);
    } catch (_) {
      // No widget support here (tests, desktop): nothing to update.
    }
  }
}

/// The widget's data: prayer names (already in the interface language)
/// with their times as epoch milliseconds, today then tomorrow.
Map<String, String> widgetData({
  required List<({String name, DateTime at})> times,
  required String title,
  required String empty,
  required String place,
}) => {
  'np_times': jsonEncode([
    for (final t in times) {'n': t.name, 't': t.at.millisecondsSinceEpoch},
  ]),
  'np_title': title,
  'np_empty': empty,
  'np_place': place,
};
