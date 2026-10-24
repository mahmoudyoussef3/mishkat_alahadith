import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/daily_hadith_notification_repo.dart';

/// Brings the server's sending in line with the reader's choice. Run when
/// the app starts, so a change made offline is applied once back online.
class SyncDailyHadithNotificationUseCase {
  final DailyHadithNotificationRepo _repo;

  SyncDailyHadithNotificationUseCase(this._repo);

  Future<ApiResult<void>> call() => _repo.syncSubscription();
}
