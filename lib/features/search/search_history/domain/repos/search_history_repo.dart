import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/search_history_entry.dart';

abstract class SearchHistoryRepo {
  Future<ApiResult<List<SearchHistoryEntry>>> getHistory();

  Future<ApiResult<void>> addEntry(NewSearchHistoryEntry entry);

  Future<ApiResult<void>> deleteEntry(int id);

  Future<ApiResult<void>> clearHistory();
}
