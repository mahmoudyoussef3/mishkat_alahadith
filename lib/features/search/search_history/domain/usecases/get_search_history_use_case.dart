import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/search_history_entry.dart';
import '../repos/search_history_repo.dart';

class GetSearchHistoryUseCase {
  final SearchHistoryRepo _repo;

  GetSearchHistoryUseCase(this._repo);

  Future<ApiResult<List<SearchHistoryEntry>>> call() => _repo.getHistory();
}
