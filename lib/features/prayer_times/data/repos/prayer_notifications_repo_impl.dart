import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/notification/prayer_time_notification_scheduler.dart';

import '../../domain/entities/prayer_notification_settings.dart';
import '../../domain/repos/prayer_notifications_repo.dart';

class PrayerNotificationsRepoImpl implements PrayerNotificationsRepo {
  @override
  Future<ApiResult<PrayerNotificationSettings>> getSettings() =>
      guardApiCall(() async {
        final results = await Future.wait([
          PrayerNotificationScheduler.isEnabled(),
          PrayerNotificationScheduler.hasBatteryOptimizationExemption(),
        ]);
        return PrayerNotificationSettings(
          enabled: results[0],
          batteryOptimizationIgnored: results[1],
        );
      });

  @override
  Future<ApiResult<String>> setEnabled(bool enabled) =>
      _run(() => PrayerNotificationScheduler.setEnabled(enabled));

  @override
  Future<ApiResult<String>> reschedule() =>
      _run(PrayerNotificationScheduler.refreshSchedule);

  @override
  Future<void> openBatteryOptimizationSettings() =>
      PrayerNotificationScheduler.openBatteryOptimizationSettings();

  Future<ApiResult<String>> _run(
    Future<PrayerNotificationActionResult> Function() action,
  ) async {
    final result = await guardApiCall(action);
    return switch (result) {
      ApiSuccess(data: final outcome) when outcome.success => ApiResult.success(
        outcome.message,
      ),
      ApiSuccess(data: final outcome) => ApiResult.failure(
        UnexpectedFailure(outcome.message),
      ),
      ApiFailure(:final failure) => ApiResult.failure(failure),
    };
  }
}
