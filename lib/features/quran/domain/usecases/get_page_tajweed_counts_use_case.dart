import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_metrics.dart';
import '../entities/tajweed_info.dart';
import '../repos/quran_repo.dart';

class GetPageTajweedCountsUseCase {
  final QuranRepo _repo;

  GetPageTajweedCountsUseCase(this._repo);

  Future<ApiResult<List<TajweedRuleCount>>> call(
    int page, {
    required bool includeNaturalMadd,
  }) async {
    if (!QuranMetrics.isValidPage(page)) {
      return const ApiResult.failure(UnexpectedFailure());
    }
    return _repo.getPageTajweedCounts(
      page,
      includeNaturalMadd: includeNaturalMadd,
    );
  }
}
