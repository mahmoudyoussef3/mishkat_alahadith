import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import '../repos/enhanced_search_repo.dart';

class GetCachedEnhancedSearchUseCase {
  final EnhancedSearchRepo _repo;

  GetCachedEnhancedSearchUseCase(this._repo);

  Future<List<ExplainedHadith>?> call(String searchTerm) =>
      _repo.getCachedResults(searchTerm);
}
