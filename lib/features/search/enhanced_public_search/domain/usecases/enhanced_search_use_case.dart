import 'package:mishkat_almasabih/core/networking/api_result.dart';

import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import '../repos/enhanced_search_repo.dart';

class EnhancedSearchUseCase {
  final EnhancedSearchRepo _repo;

  EnhancedSearchUseCase(this._repo);

  Future<ApiResult<List<ExplainedHadith>>> call(String searchTerm) =>
      _repo.search(searchTerm);
}
