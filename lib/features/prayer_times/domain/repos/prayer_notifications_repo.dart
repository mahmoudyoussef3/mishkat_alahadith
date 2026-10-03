import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/prayer_notification_settings.dart';

abstract class PrayerNotificationsRepo {
  Future<ApiResult<PrayerNotificationSettings>> getSettings();

  Future<ApiResult<String>> setEnabled(bool enabled);

  Future<ApiResult<String>> reschedule();

  Future<void> openBatteryOptimizationSettings();
}
