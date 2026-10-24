import 'dart:async';

import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/daily_hadith_notification_repo.dart';

/// Turns the "حديث اليوم" notification on or off: saves the choice, then
/// has the server start or stop sending it.
class SetDailyHadithNotificationEnabledUseCase {
  final DailyHadithNotificationRepo _repo;

  SetDailyHadithNotificationEnabledUseCase(this._repo);

  /// Done once the choice is saved. The server is told without waiting:
  /// offline, FCM sends the change once back online, and the app sends it
  /// again on every start.
  Future<ApiResult<void>> call(bool enabled) async {
    final saved = await _repo.setEnabled(enabled);
    if (saved is ApiSuccess) unawaited(_repo.syncSubscription());
    return saved;
  }
}
