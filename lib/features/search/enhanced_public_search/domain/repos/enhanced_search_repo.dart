import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

abstract class EnhancedSearchRepo {
  Future<List<ExplainedHadith>?> getCachedResults(String searchTerm);

  Future<ApiResult<List<ExplainedHadith>>> search(String searchTerm);
}
