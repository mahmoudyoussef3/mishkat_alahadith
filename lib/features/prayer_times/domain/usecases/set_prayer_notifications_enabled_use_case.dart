import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/prayer_notifications_repo.dart';

class SetPrayerNotificationsEnabledUseCase {
  final PrayerNotificationsRepo _repo;

  SetPrayerNotificationsEnabledUseCase(this._repo);

  Future<ApiResult<String>> call(bool enabled) => _repo.setEnabled(enabled);
}
