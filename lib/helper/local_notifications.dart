import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ramadhan_companion_app/main.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> scheduleNotification({
  required int id,
  required String title,
  required String body,
  required DateTime scheduledDate,
}) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.from(scheduledDate, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'prayer_channel_id',
        'Prayer Notifications',
        channelDescription: 'Notifications for prayer times',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time, // repeat daily
    // ⛔️ Removed: uiLocalNotificationDateInterpretation
  );
}


Future<void> ensureExactAlarmPermission() async {
  try {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
  } on PlatformException catch (e) {
    if (e.code == 'permissionRequestInProgress') {
      debugPrint("Permission request already in progress. Ignoring.");
    } else {
      rethrow;
    }
  }
}
