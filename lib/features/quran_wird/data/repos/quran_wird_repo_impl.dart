import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../../domain/repos/quran_wird_repo.dart';
import '../datasources/quran_wird_reminder_datasource.dart';

class QuranWirdRepoImpl implements QuranWirdRepo {
  final QuranWirdReminderDataSource _reminders;

  QuranWirdRepoImpl(this._reminders);

  @override
  Future<ApiResult<bool>> isReminderEnabled() =>
      guardApiCall(_reminders.isEnabled);

  @override
  Future<ApiResult<void>> setReminderEnabled(bool enabled) async {
    final result = await guardApiCall(() => _reminders.setEnabled(enabled));
    return switch (result) {
      ApiSuccess(data: true) => const ApiResult.success(null),
      ApiSuccess(data: false) => const ApiResult.failure(
        UnexpectedFailure(FailureMessages.notificationsDenied),
      ),
      ApiFailure(:final failure) => ApiResult.failure(failure),
    };
  }

  @override
  Future<ApiResult<void>> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) => guardApiCall(
    () => _reminders.scheduleDaily(hour: hour, minute: minute),
  );

  @override
  Future<ApiResult<void>> cancelReminder() => guardApiCall(_reminders.cancel);
}
