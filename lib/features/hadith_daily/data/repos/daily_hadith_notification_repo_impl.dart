import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../../domain/repos/daily_hadith_notification_repo.dart';
import '../datasources/daily_hadith_notification_datasource.dart';

class DailyHadithNotificationRepoImpl implements DailyHadithNotificationRepo {
  final DailyHadithNotificationDataSource _dataSource;

  DailyHadithNotificationRepoImpl(this._dataSource);

  @override
  Future<ApiResult<bool>> isEnabled() => guardApiCall(_dataSource.isEnabled);

  @override
  Future<ApiResult<void>> setEnabled(bool enabled) async {
    final result = await guardApiCall(() => _dataSource.setEnabled(enabled));
    return switch (result) {
      ApiSuccess(data: true) => const ApiResult.success(null),
      ApiSuccess(data: false) => const ApiResult.failure(
        UnexpectedFailure(FailureMessages.notificationsDenied),
      ),
      ApiFailure(:final failure) => ApiResult.failure(failure),
    };
  }

  /// FCM confirms a topic change only once online, so not hearing back is
  /// taken as being offline.
  @override
  Future<ApiResult<void>> syncSubscription() async {
    final result = await guardApiCall(_dataSource.syncSubscription);
    return switch (result) {
      ApiSuccess() => const ApiResult.success(null),
      ApiFailure() => const ApiResult.failure(NetworkFailure()),
    };
  }
}
