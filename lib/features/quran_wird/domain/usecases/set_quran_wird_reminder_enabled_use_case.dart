import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/quran_wird_repo.dart';
import 'sync_quran_wird_reminder_use_case.dart';

/// Turns the daily wird reminder on, scheduling it at once, or off, clearing
/// it.
class SetQuranWirdReminderEnabledUseCase {
  final QuranWirdRepo _repo;
  final SyncQuranWirdReminderUseCase _sync;

  SetQuranWirdReminderEnabledUseCase(this._repo, this._sync);

  Future<ApiResult<void>> call(bool enabled) async {
    final saved = await _repo.setReminderEnabled(enabled);
    if (saved is ApiFailure) return saved;
    return _sync();
  }
}
