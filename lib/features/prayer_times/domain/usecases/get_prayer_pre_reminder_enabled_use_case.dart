import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/prayer_notifications_repo.dart';

class GetPrayerPreReminderEnabledUseCase {
  final PrayerNotificationsRepo _repo;

  GetPrayerPreReminderEnabledUseCase(this._repo);

  Future<ApiResult<bool>> call() => _repo.isPreReminderEnabled();
}
