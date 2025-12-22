import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mishkat_almasabih/core/notification/firebase_service/notification_factories.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalNotification {
  static Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static StreamController<NotificationResponse> streamController =
      StreamController<NotificationResponse>.broadcast();

  static Future<void> init() async {
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
      await flutterLocalNotificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        RepeatInterval.everyMinute,
        platformDetails,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      // Fallback: show once to avoid complete failure (especially iOS)
      await flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );
    }
  }

  /// Cancel a previously scheduled reminder using its unique ID.
  static Future<void> cancelReminder(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
    } catch (_) {}
  }
}
