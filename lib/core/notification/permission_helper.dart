import 'dart:developer';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PermissionHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<bool> requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      return await _requestAndroidPermissions();
    } else if (Platform.isIOS) {
      return await _requestIOSPermissions();
    }
    return true;
  }

  static Future<bool> _requestAndroidPermissions() async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) {
      log('Android plugin not available');
      return false;
    }

    final notificationGranted = await androidPlugin.requestNotificationsPermission();
    log('Notification permission granted: $notificationGranted');

    if (notificationGranted != true) {
      return false;
    }

    final exactAlarmGranted = await androidPlugin.requestExactAlarmsPermission();
    log('Exact alarm permission granted: $exactAlarmGranted');

    return true;
  }

  static Future<bool> _requestIOSPermissions() async {
    final iosPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin == null) {
      log('iOS plugin not available');
      return false;
    }

    final granted = await iosPlugin.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    log('iOS notification permission granted: $granted');
    return granted ?? false;
  }

  static Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.areNotificationsEnabled() ?? false;
    } else if (Platform.isIOS) {
      return true;
    }
    return false;
  }

  static Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;

    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return false;

    return await androidPlugin.canScheduleExactNotifications() ?? false;
  }
}
