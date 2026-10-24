import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mishkat_almasabih/core/notification/local_notification.dart';
import 'package:mishkat_almasabih/core/notification/notification_choice.dart';
import 'package:mishkat_almasabih/core/notification/notification_payloads.dart';
import 'package:mishkat_almasabih/core/notification/notification_style.dart';
import 'package:timezone/timezone.dart' as tz;

/// The daily "الورد اليومي" reminder: the reader's choice, and the one
/// notification that repeats every day.
class QuranWirdReminderDataSource {
  /// Off until the reader turns it on.
  static const NotificationChoice _choice = NotificationChoice(
    'quran_wird_reminder_enabled',
    defaultEnabled: false,
  );

  /// Clear of the ids other notifications use: prayer reminders are numbered
  /// by date in the low hundreds of millions, or a billion higher for those
  /// before the adhan, daily ayahs from 700 million up by the day, and pushes
  /// by the second they arrive.
  static const int _notificationId = 710000000;

  static const String _channelId = 'quran_wird';
  static const String _channelName = 'الورد اليومي';
  static const String _channelDescription =
      'تذكير يومي بقراءة وردك من القرآن الكريم';

  static const String _title = 'وردك اليومي من القرآن';
  static const String _body = 'حان وقت وردك، تابع القراءة من حيث توقفت';

  final FlutterLocalNotificationsPlugin _plugin;

  QuranWirdReminderDataSource({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  Future<bool> isEnabled() => _choice.isEnabled();

  Future<bool> setEnabled(bool enabled) => _choice.setEnabled(enabled);

  /// Replaces the pending reminder with one every day at [hour]:[minute],
  /// local time.
  ///
  /// Inexact on purpose: a few minutes either way does not matter for a
  /// reading reminder, and needs no exact alarm permission.
  Future<void> scheduleDaily({required int hour, required int minute}) async {
    await LocalNotification.configureLocalTimeZone();
    final now = tz.TZDateTime.now(tz.local);
    var fireAt = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!fireAt.isAfter(now)) {
      // Built from the date, not by adding hours, so a daylight saving change
      // cannot move it off the hour.
      fireAt = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day + 1,
        hour,
        minute,
      );
    }

    await _plugin.zonedSchedule(
      _notificationId,
      _title,
      _body,
      fireAt,
      _details,
      payload: NotificationPayloads.quranWird,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancel() => _plugin.cancel(_notificationId);

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      icon: 'ic_notification',
      color: NotificationStyle.accent,
    ),
    iOS: DarwinNotificationDetails(),
  );
}
