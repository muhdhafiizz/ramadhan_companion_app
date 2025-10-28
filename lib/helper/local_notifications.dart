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
  bool playAdhan = false, 
}) async {
  final notificationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'prayer_channel_id',
      'Prayer Notifications',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.max,
      priority: Priority.high,
      sound: playAdhan
          ? RawResourceAndroidNotificationSound(
              'adhan_notification_cut',
            ) 
          : null, 
      playSound: true,
    ),
    iOS: DarwinNotificationDetails(sound: playAdhan ? 'adhan_notification_cut.caf' : null),
  );

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.from(scheduledDate, tz.local),
    notificationDetails,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
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

Future<void> requestNotificationPermissions() async {
  final androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  if (androidImplementation != null) {
    await androidImplementation.requestNotificationsPermission();
  }

  final iosImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

  if (iosImplementation != null) {
    await iosImplementation.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

