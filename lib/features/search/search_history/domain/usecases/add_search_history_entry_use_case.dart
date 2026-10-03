import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/search_history_entry.dart';
import '../repos/search_history_repo.dart';

class AddSearchHistoryEntryUseCase {
  final SearchHistoryRepo _repo;

  AddSearchHistoryEntryUseCase(this._repo);

  Future<ApiResult<void>> call(NewSearchHistoryEntry entry) =>
      _repo.addEntry(entry);
}
