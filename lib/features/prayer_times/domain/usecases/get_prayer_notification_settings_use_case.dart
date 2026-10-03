import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/prayer_notification_settings.dart';
import '../repos/prayer_notifications_repo.dart';

class GetPrayerNotificationSettingsUseCase {
  final PrayerNotificationsRepo _repo;

  GetPrayerNotificationSettingsUseCase(this._repo);

  Future<ApiResult<PrayerNotificationSettings>> call() => _repo.getSettings();
}
