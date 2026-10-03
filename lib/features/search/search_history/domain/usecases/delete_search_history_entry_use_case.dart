import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/search_history_repo.dart';

class DeleteSearchHistoryEntryUseCase {
  final SearchHistoryRepo _repo;

  DeleteSearchHistoryEntryUseCase(this._repo);

  Future<ApiResult<void>> call(int id) => _repo.deleteEntry(id);
}
