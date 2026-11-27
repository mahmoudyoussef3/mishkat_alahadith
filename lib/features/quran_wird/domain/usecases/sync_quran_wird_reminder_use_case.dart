import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/quran_wird_repo.dart';

/// Keeps the daily wird reminder in line with the reader's choice: due every
/// day at [reminderHour] while it is on, cleared while it is off.
///
/// Run when the app starts too, so a reminder lost along the way, or held
/// back while the permission was off, is set again.
class SyncQuranWirdReminderUseCase {
  /// The hour, local time, the reminder goes out: the evening, once the
  /// day's work is done.
  static const int reminderHour = 20;

  final QuranWirdRepo _repo;

  SyncQuranWirdReminderUseCase(this._repo);

  Future<ApiResult<void>> call() async {
    switch (await _repo.isReminderEnabled()) {
      case ApiFailure(:final failure):
        return ApiResult.failure(failure);
      case ApiSuccess(data: true):
        return _repo.scheduleDailyReminder(hour: reminderHour, minute: 0);
      case ApiSuccess(data: false):
        return _repo.cancelReminder();
    }
  }
}
