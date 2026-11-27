import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

abstract class RandomAhadithRepo {
  Future<ApiResult<List<ExplainedHadith>>> getRandomAhadith();

  /// The last selection fetched, however old; null when none was.
  Future<List<ExplainedHadith>?> getCachedRandomAhadith();
}
