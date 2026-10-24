import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/daily_hadith_notification_repo.dart';

class GetDailyHadithNotificationEnabledUseCase {
  final DailyHadithNotificationRepo _repo;

  GetDailyHadithNotificationEnabledUseCase(this._repo);

  Future<ApiResult<bool>> call() => _repo.isEnabled();
}
