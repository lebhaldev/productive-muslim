import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// One repeating daily notification.
class Reminder {
  const Reminder({
    required this.id,
    required this.time,
    required this.title,
    required this.body,
  });

  final int id;
  final String time; // HH:mm local
  final String title;
  final String body;

  @override
  bool operator ==(Object other) =>
      other is Reminder &&
      other.id == id &&
      other.time == time &&
      other.title == title &&
      other.body == body;

  @override
  int get hashCode => Object.hash(id, time, title, body);

  @override
  String toString() => 'Reminder($id $time $title)';
}

const dailyReminderId = 0;

/// The full set of reminders implied by settings and habits. Archived habits
/// and habits without a time get none.
List<Reminder> planReminders({
  required String? dailyTime,
  required List<({int id, String name, String? time, bool archived})> habits,
}) => [
  if (dailyTime != null)
    Reminder(
      id: dailyReminderId,
      time: dailyTime,
      title: 'Your day in Nurday',
      body: 'Check your habits and write a few lines.',
    ),
  for (final h in habits)
    if (!h.archived && h.time != null)
      Reminder(
        id: 1000 + h.id,
        time: h.time!,
        title: h.name,
        body: 'Time for: ${h.name}',
      ),
];

abstract class ReminderScheduler {
  /// Replaces every scheduled reminder with [plan].
  Future<void> sync(List<Reminder> plan);
}

/// Local notifications only; nothing leaves the phone.
class LocalReminderScheduler implements ReminderScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      // Fall back to UTC offsets from the device clock.
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _ready = true;
  }

  @override
  Future<void> sync(List<Reminder> plan) async {
    await _init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await _plugin.cancelAllPendingNotifications();
    if (plan.isEmpty) return;
    await android?.requestNotificationsPermission();
    for (final r in plan) {
      final parts = r.time.split(':').map(int.parse).toList();
      final now = tz.TZDateTime.now(tz.local);
      var at = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        parts[0],
        parts[1],
      );
      if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
      await _plugin.zonedSchedule(
        id: r.id,
        scheduledDate: at,
        title: r.title,
        body: r.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            r.id == dailyReminderId ? 'daily' : 'habits',
            r.id == dailyReminderId ? 'Daily reminder' : 'Habit reminders',
            importance: Importance.defaultImportance,
          ),
        ),
        // Inexact is enough for a gentle reminder and needs no extra permission.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
}
