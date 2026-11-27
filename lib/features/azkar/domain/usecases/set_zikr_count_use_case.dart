import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/azkar_day_progress.dart';
import '../repos/azkar_repo.dart';

/// Records how many times a zikr has been said on [day]; zero clears it.
///
/// Counts from an earlier day are dropped on the first count of a new one.
/// A count for a [day] that has already passed — a screen left open
/// overnight — is not recorded at all: the result is then a fresh today,
/// for the caller to show in place of its stale counts.
class SetZikrCountUseCase {
  final AzkarRepo _repo;
  final DateTime Function() _now;

  SetZikrCountUseCase(this._repo, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  /// A null [day] records the count on today, whatever it is.
  Future<ApiResult<AzkarDayProgress>> call({
    required int categoryId,
    required int zikrId,
    required int count,
    DateTime? day,
  }) {
    final now = _now();
    return _repo.updateProgress((stored) {
      final today = AzkarDayProgress.currentOf(stored, now);
      if (day != null && day != today.day) return today;
      return today.withCount(categoryId, zikrId, count);
    });
  }
}
