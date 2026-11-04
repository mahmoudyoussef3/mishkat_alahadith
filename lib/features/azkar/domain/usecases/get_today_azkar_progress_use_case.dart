import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/azkar_day_progress.dart';
import '../repos/azkar_repo.dart';

/// What was counted today; empty when the stored counts are from an earlier
/// day.
class GetTodayAzkarProgressUseCase {
  final AzkarRepo _repo;
  final DateTime Function() _now;

  GetTodayAzkarProgressUseCase(this._repo, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  Future<ApiResult<AzkarDayProgress>> call() async {
    final result = await _repo.getProgress();
    return switch (result) {
      ApiFailure(:final failure) => ApiResult.failure(failure),
      ApiSuccess(data: final stored) => ApiResult.success(
        AzkarDayProgress.currentOf(stored, _now()),
      ),
    };
  }
}
