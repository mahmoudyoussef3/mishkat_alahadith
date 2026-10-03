import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/search_history_repo.dart';

class ClearSearchHistoryUseCase {
  final SearchHistoryRepo _repo;

  ClearSearchHistoryUseCase(this._repo);

  Future<ApiResult<void>> call() => _repo.clearHistory();
}
