import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/daily_ayah_repo.dart';
import 'sync_daily_ayah_use_case.dart';

/// Turns the daily notification on, scheduling the coming days at once, or
/// off, clearing those already scheduled.
class SetDailyAyahReminderEnabledUseCase {
  final DailyAyahRepo _repo;
  final SyncDailyAyahUseCase _sync;

  SetDailyAyahReminderEnabledUseCase(this._repo, this._sync);

  Future<ApiResult<void>> call(bool enabled) async {
    final saved = await _repo.setReminderEnabled(enabled);
    if (saved is ApiFailure) return saved;
    return enabled ? _sync() : _repo.cancelReminders();
  }
}
