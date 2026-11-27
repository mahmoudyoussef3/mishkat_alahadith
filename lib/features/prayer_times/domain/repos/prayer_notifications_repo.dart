import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/prayer_notification_settings.dart';

abstract class PrayerNotificationsRepo {
  Future<ApiResult<PrayerNotificationSettings>> getSettings();

  Future<ApiResult<String>> setEnabled(bool enabled);

  Future<ApiResult<String>> reschedule();

  Future<void> openBatteryOptimizationSettings();

  /// Whether the reader wants a reminder shortly before each adhan.
  Future<ApiResult<bool>> isPreReminderEnabled();

  /// Saves the reader's choice, rescheduling while prayer notifications are
  /// on.
  Future<ApiResult<void>> setPreReminderEnabled(bool enabled);
}
