import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/prayer_notifications_repo.dart';

/// Turns the reminder shortly before each adhan on or off.
class SetPrayerPreReminderEnabledUseCase {
  final PrayerNotificationsRepo _repo;

  SetPrayerPreReminderEnabledUseCase(this._repo);

  Future<ApiResult<void>> call(bool enabled) =>
      _repo.setPreReminderEnabled(enabled);
}
