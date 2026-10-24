import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/daily_ayah_repo.dart';

class GetDailyAyahReminderEnabledUseCase {
  final DailyAyahRepo _repo;

  GetDailyAyahReminderEnabledUseCase(this._repo);

  Future<ApiResult<bool>> call() => _repo.isReminderEnabled();
}
