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

    // On Android 12+ (API 31+), exact alarms require explicit user permission.
    // This permission cannot be requested via a normal dialog - it opens Settings.
    try {
      final status = await Permission.scheduleExactAlarm.status;

      if (status.isGranted) {
        log('Exact alarm permission: GRANTED');
        return true;
      }

      log('Exact alarm permission not granted. Status: $status');
      log('Opening system settings for exact alarm permission...');

      // On Android 12+, request() opens the system settings page
      // where the user must manually enable "Alarms & reminders"
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
      // If permission check fails (older Android), assume it's okay
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
    // 1. Configure iOS initialization settings
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

    // 2. Initialize settings for both platforms
    InitializationSettings settings = const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: iOSSettings,
    );

    // 3. Initialize plugin with proper error handling
    try {
      await flutterLocalNotificationsPlugin.initialize(
        settings,
        onDidReceiveNotificationResponse: onTap,
        onDidReceiveBackgroundNotificationResponse: onTap,
      );

      // Request notification permission on Android 13+ using the plugin API.
      if (Platform.isAndroid) {
        await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >()
            ?.requestNotificationsPermission();

        // Best-effort: request exact alarm permission so scheduled reminders
        // (like prayer times) can fire reliably on Android 12+.
        await _ensureExactAlarmPermissionIfNeeded();
      }

      // 4. Request permissions explicitly for iOS
      if (Platform.isIOS) {
        final bool? result = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(
              alert: true, // Request alert permission again
              badge: true,
              sound: true,
              critical: true, // Enable critical alerts
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
      // Fallback: keep default timezone configuration.
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

    // 1. Create iOS-specific notification details
    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true, // Crucial for showing the banner
      presentBadge: true,
      presentBanner: true,
      presentSound: true,
      presentList: true,
      sound: 'default',
    );

    // 2. Create Android notification details
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

    // 3. Combine platform-specific details
    const NotificationDetails platformDetails = NotificationDetails(
      iOS: iOSDetails,
      android: androidDetails,
    );

    try {
      // 4. Show the notification with a unique ID based on timestamp
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

  /// Schedule an hourly reminder notification for a specific section.
  ///
  /// Uses `periodicallyShow` on Android. On iOS, attempts to use the closest
  /// available scheduling option; if not supported, will display immediately
  /// once and rely on push or manual triggers.
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
      // Ensure we don't keep an old schedule with the same id.
      await cancelReminder(id);

      await flutterLocalNotificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        everyMinute ? RepeatInterval.everyMinute : RepeatInterval.hourly,
        platformDetails,
        payload: payload,
        // Android 12+ may restrict exact alarms; for periodic reminders,
        // prefer inexact scheduling to avoid silent failures (esp. Android 15).
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      log('Error scheduling periodic reminder (id=$id): $e');

      // Last resort: show once (verifies channel + permission are OK).
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    }
  }

  /// Schedule a one-time notification at an exact date/time.
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
        // If exact alarms aren't allowed, fall back to inexact scheduling
        // rather than silently failing.
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

  /// Cancel a previously scheduled reminder using its unique ID.
  static Future<void> cancelReminder(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
    } catch (_) {}
  }
}
