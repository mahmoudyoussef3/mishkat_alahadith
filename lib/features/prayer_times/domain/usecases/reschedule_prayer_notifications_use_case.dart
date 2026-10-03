import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/prayer_notifications_repo.dart';

class ReschedulePrayerNotificationsUseCase {
  final PrayerNotificationsRepo _repo;

  ReschedulePrayerNotificationsUseCase(this._repo);

  Future<ApiResult<String>> call() => _repo.reschedule();
}
