import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/azkar_day_progress.dart';
import '../repos/azkar_repo.dart';

/// Clears today's counts for one chapter, to say it again from the start.
class ResetAzkarCategoryUseCase {
  final AzkarRepo _repo;
  final DateTime Function() _now;

  ResetAzkarCategoryUseCase(this._repo, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  Future<ApiResult<AzkarDayProgress>> call(int categoryId) {
    final now = _now();
    return _repo.updateProgress(
      (stored) =>
          AzkarDayProgress.currentOf(stored, now).withoutCategory(categoryId),
    );
  }
}
