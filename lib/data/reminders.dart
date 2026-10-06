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
    this.at,
  });

  final int id;
  final String time; // HH:mm local

  /// Set for a one-off reminder (prayer times); null repeats daily at [time].
  final DateTime? at;
  final String title;
  final String body;

  @override
  bool operator ==(Object other) =>
      other is Reminder &&
      other.id == id &&
      other.time == time &&
      other.title == title &&
      other.body == body &&
      other.at == at;

  @override
  int get hashCode => Object.hash(id, time, title, body, at);

  @override
  String toString() => 'Reminder($id $time $title)';
}

const dailyReminderId = 0;

/// Prayer reminders use ids 2000 + day * 5 + prayer index.
const prayerReminderBase = 2000;

/// The full set of reminders implied by settings and habits. Archived habits
/// and habits without a time get none.
List<Reminder> planReminders({
  required String? dailyTime,
  required List<({int id, String name, String? time, bool archived})> habits,
  List<({String name, DateTime at, String place})> prayers = const [],
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
  for (final (i, p) in prayers.indexed)
    Reminder(
      id: prayerReminderBase + i,
      time: _hhmm(p.at),
      title: p.name,
      body: '${p.name} at ${_hhmm(p.at)} · ${p.place}',
      at: p.at,
    ),
];

String _hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

abstract class ReminderScheduler {
  /// Asks for the notification permission. Call only from a user action.
  Future<bool> requestPermission();

  /// Replaces every scheduled reminder with [plan]. Never prompts.
  Future<void> sync(List<Reminder> plan);
}

/// Local notifications only; nothing leaves the phone.
class LocalReminderScheduler implements ReminderScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> _init() async {
    // Re-read the zone every time so travel or a zone change is picked up.
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      if (!_ready) tzdata.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      // Keep the previous zone.
    }
    if (_ready) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _ready = true;
  }

  @override
  Future<bool> requestPermission() async {
    await _init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? true;
  }

  @override
  Future<void> sync(List<Reminder> plan) async {
    await _init();
    await _plugin.cancelAllPendingNotifications();
    for (final r in plan) {
      if (r.at != null) {
        await _plugin.zonedSchedule(
          id: r.id,
          scheduledDate: tz.TZDateTime.from(r.at!, tz.local),
          title: r.title,
          body: r.body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer',
              'Prayer times',
              importance: Importance.defaultImportance,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
        continue;
      }
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
      if (!at.isAfter(now)) {
        // Build tomorrow's wall-clock time, so DST changes don't shift it.
        at = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day + 1,
          parts[0],
          parts[1],
        );
      }
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
