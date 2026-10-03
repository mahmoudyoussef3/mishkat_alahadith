import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mishkat_almasabih/core/notification/firebase_service/notification_factories.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotification {
  static bool _timeZoneConfigured = false;

  static Future<void> requestNotificationPermission() async {
    final status = await Permission.notification.status;

    if (status.isGranted) return;

    final requestedStatus = await Permission.notification.request();
    log('Notification permission status: $requestedStatus');

    if (requestedStatus.isPermanentlyDenied) {
      log(
        'Notification permission permanently denied; user must enable it from system settings.',
      );
    }
  }
  

  static Future<bool> _ensureExactAlarmPermissionIfNeeded() async {
    if (!Platform.isAndroid) return true;

    try {
      final status = await Permission.scheduleExactAlarm.status;

      if (status.isGranted) {
        log('Exact alarm permission: GRANTED');
        return true;
      }

      log('Exact alarm permission not granted. Status: $status');
      log('Opening system settings for exact alarm permission...');

      final requested = await Permission.scheduleExactAlarm.request();

      log('Exact alarm permission after request: $requested');

      if (!requested.isGranted) {
        log(
          '⚠️ Exact alarm permission denied. Prayer time notifications may not work accurately.',
        );
        log(
          'Users should enable "Alarms & reminders" in app settings for precise prayer notifications.',
        );
      }

      return requested.isGranted;
    } catch (e) {
      log('Exact alarm permission check failed: $e');
      return true;
    }
  }

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static StreamController<NotificationResponse> streamController =
      StreamController<NotificationResponse>.broadcast();

  static Future<void> init() async {
    await requestNotificationPermission();
    await _configureLocalTimeZone();
    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          requestProvisionalPermission: true,
          requestCriticalPermission: true,
          defaultPresentAlert: true,
          defaultPresentSound: true,
          defaultPresentBadge: true,
          defaultPresentBanner: true,
          defaultPresentList: true,
        );

    InitializationSettings settings = const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: iOSSettings,
    );

    try {
      await flutterLocalNotificationsPlugin.initialize(
        settings,
        onDidReceiveNotificationResponse: onTap,
        onDidReceiveBackgroundNotificationResponse: onTap,
      );

      if (Platform.isAndroid) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();

        await _ensureExactAlarmPermissionIfNeeded();
      }

      if (Platform.isIOS) {
        final bool? result = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
              critical: true,
            );
        log('iOS permission request result: $result');
      }
      log('Local notifications initialized successfully');
    } catch (e) {
      log('Error initializing local notifications: $e');
    }
  }

  static Future<void> _configureLocalTimeZone() async {
    if (_timeZoneConfigured) return;
    try {
      tz.initializeTimeZones();
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      _timeZoneConfigured = true;
    } catch (e) {
      log('Error configuring local timezone: $e');
    }
  }

  static void onTap(NotificationResponse notificationResponse) {
    log('Notification tapped - payload: ${notificationResponse.payload}');

    if (notificationResponse.payload != null) {
      final payloadData = notificationResponse.payload!;
      final navigatingHandler = NotificationHandlerFactory.getHandler(
        payloadData,
      );
      navigatingHandler?.handleOnTap();
    }

    streamController.add(notificationResponse);
  }

  static Future<void> forgroundNotificationHandler(
    RemoteMessage message,
  ) async {
    log('Handling foreground notification: ${message.messageId}');

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentBanner: true,
      presentSound: true,
      presentList: true,
      sound: 'default',
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'id_1',
          'Renew Your Order',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          ticker: 'ticker',
        );

    const NotificationDetails platformDetails = NotificationDetails(
      iOS: iOSDetails,
      android: androidDetails,
    );

    try {
      final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await flutterLocalNotificationsPlugin.show(
        notificationId,
        message.notification?.title,
        message.notification?.body,
        platformDetails,
        payload: message.data['type'],
      );
      log('Foreground notification displayed successfully');
      log('Title: ${message.notification?.title}');
      log('Body: ${message.notification?.body}');
    } catch (e) {
      log('Error showing foreground notification: $e');
    }
  }

  static Future<void> scheduleHourlyReminder({
    required int id,
    required String channelId,
    required String channelName,
    required String title,
    required String body,
    String? payload,
    bool everyMinute = false,
  }) async {
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentBanner: true,
      presentSound: true,
      sound: 'default',
    );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          ticker: 'ticker',
        );

    final NotificationDetails platformDetails = NotificationDetails(
      iOS: iOSDetails,
      android: androidDetails,
    );

    try {
      await cancelReminder(id);

      await flutterLocalNotificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        everyMinute ? RepeatInterval.everyMinute : RepeatInterval.hourly,
        platformDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      log('Error scheduling periodic reminder (id=$id): $e');

      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    }
  }

  static Future<void> scheduleOneTimeNotification({
    required int id,
    required String channelId,
    required String channelName,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await _configureLocalTimeZone();

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentBanner: true,
      presentSound: true,
      sound: 'default',
    );

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          ticker: 'ticker',
        );

    final NotificationDetails platformDetails = NotificationDetails(
      iOS: iOSDetails,
      android: androidDetails,
    );

    try {
      await cancelReminder(id);
      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

      final canUseExactAlarms = await _ensureExactAlarmPermissionIfNeeded();
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        platformDetails,
        payload: payload,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode:
            canUseExactAlarms
                ? AndroidScheduleMode.exactAllowWhileIdle
                : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      log('Error scheduling one-time notification (id=$id): $e');
    }
  }

  static Future<void> cancelReminders(Iterable<int> ids) async {
    for (final id in ids) {
      await cancelReminder(id);
    }
  }

  static Future<void> cancelReminder(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
    } catch (_) {}
  }
}
