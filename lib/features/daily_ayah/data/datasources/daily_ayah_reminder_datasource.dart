import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mishkat_almasabih/core/notification/daily_ayah_payload.dart';
import 'package:mishkat_almasabih/core/notification/local_notification.dart';
import 'package:mishkat_almasabih/core/notification/notification_choice.dart';
import 'package:mishkat_almasabih/core/notification/notification_style.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/daily_ayah_notification.dart';

/// The daily "آية اليوم" notification: the reader's choice, and the
/// notifications themselves, scheduled ahead one per day.
class DailyAyahReminderDataSource {
  /// On until the reader turns it off.
  static const NotificationChoice _choice = NotificationChoice(
    'daily_ayah_reminder_enabled',
    defaultEnabled: true,
  );

  static const String _channelId = 'daily_ayah';
  static const String _channelName = 'آية اليوم';
  static const String _channelDescription = 'آية من القرآن الكريم كل صباح';

  final FlutterLocalNotificationsPlugin _plugin;
  final DateTime Function() _now;

  DailyAyahReminderDataSource({
    FlutterLocalNotificationsPlugin? plugin,
    DateTime Function()? now,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _now = now ?? DateTime.now;

  Future<bool> isEnabled() => _choice.isEnabled();

  /// Returns whether the choice was saved; see [NotificationChoice.setEnabled].
  Future<bool> setEnabled(bool enabled) => _choice.setEnabled(enabled);

  /// Replaces the pending daily ayah notifications with [notifications].
  ///
  /// Inexact on purpose: a few minutes either way does not matter for a
  /// morning reminder, and needs no exact alarm permission.
  Future<void> schedule(List<DailyAyahNotification> notifications) async {
    await LocalNotification.configureLocalTimeZone();
    await cancelAll();
    for (final notification in notifications) {
      // One that fell due while the sync ran would be refused, and take the
      // rest of the days down with it.
      if (!notification.fireAt.isAfter(_now())) continue;
      await _plugin.zonedSchedule(
        notification.id,
        notification.title,
        notification.body,
        tz.TZDateTime.from(notification.fireAt, tz.local),
        _details(notification),
        payload: notification.payload,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// Cancels every pending daily ayah notification, found by its payload so
  /// no other kind of notification is touched.
  Future<void> cancelAll() async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      if (DailyAyahPayload.tryParse(request.payload) != null) {
        await _plugin.cancel(request.id);
      }
    }
  }

  NotificationDetails _details(DailyAyahNotification notification) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          icon: 'ic_notification',
          color: NotificationStyle.accent,
          subText: notification.subtitle,
          // An ayah is often longer than one line; show all of it.
          styleInformation: BigTextStyleInformation(notification.body),
        ),
        iOS: DarwinNotificationDetails(subtitle: notification.subtitle),
      );
}
