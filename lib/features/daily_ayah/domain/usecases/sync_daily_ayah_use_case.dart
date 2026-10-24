import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/daily_ayah.dart';
import '../repos/daily_ayah_repo.dart';
import 'get_daily_ayahs_use_case.dart';

/// Prepares the coming days of "آية اليوم": the home screen widget always,
/// and the daily notification when the reader wants it.
///
/// Run when the app starts and, on Android, once a day in the background, so
/// both keep moving on daily for as long as the app stays closed. iOS runs no
/// background sync, so there the days prepared at the last start are all
/// there is.
class SyncDailyAyahUseCase {
  /// The hour, local time, the day's notification goes out.
  static const int reminderHour = 8;

  static const int defaultDaysAhead = 30;

  final GetDailyAyahsUseCase _getDailyAyahs;
  final DailyAyahRepo _repo;
  final int _daysAhead;
  final DateTime Function() _now;

  /// [daysAhead] is how many days, today included, are prepared at once.
  SyncDailyAyahUseCase(
    this._getDailyAyahs,
    this._repo, {
    int daysAhead = defaultDaysAhead,
    DateTime Function()? now,
  }) : _daysAhead = daysAhead,
       _now = now ?? DateTime.now;

  Future<ApiResult<void>> call() async {
    final now = _now();
    switch (await _getDailyAyahs(from: now, days: _daysAhead)) {
      case ApiFailure(:final failure):
        return ApiResult.failure(failure);
      case ApiSuccess(data: final ayahs):
        final (widget, reminders) =
            await (
              _repo.updateHomeWidget(ayahs),
              _syncReminders(ayahs, now),
            ).wait;
        return switch ((widget, reminders)) {
          (ApiFailure(:final failure), _) || (_, ApiFailure(:final failure)) =>
            ApiResult.failure(failure),
          _ => const ApiResult.success(null),
        };
    }
  }

  Future<ApiResult<void>> _syncReminders(
    List<DailyAyah> ayahs,
    DateTime now,
  ) async {
    switch (await _repo.isReminderEnabled()) {
      case ApiFailure(:final failure):
        return ApiResult.failure(failure);
      case ApiSuccess(data: true):
        return _repo.scheduleReminders(remindersFor(ayahs, now: now));
      case ApiSuccess(data: false):
        return _repo.cancelReminders();
    }
  }

  /// A notification at [reminderHour] on each of [ayahs]' days, leaving out
  /// those already past at [now].
  static List<DailyAyahReminder> remindersFor(
    List<DailyAyah> ayahs, {
    required DateTime now,
  }) => [
    for (final dailyAyah in ayahs)
      if (DateTime(
            dailyAyah.day.year,
            dailyAyah.day.month,
            dailyAyah.day.day,
            reminderHour,
          )
          case final fireAt when fireAt.isAfter(now))
        (fireAt: fireAt, dailyAyah: dailyAyah),
  ];
}
