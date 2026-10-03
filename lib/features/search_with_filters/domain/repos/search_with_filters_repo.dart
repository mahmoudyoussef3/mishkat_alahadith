import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/domain/entities/chapter_hadith.dart';

import '../entities/hadith_search_filters.dart';

abstract class SearchWithFiltersRepo {
  Future<List<ChapterHadith>?> getCachedResults(HadithSearchFilters filters);

  Future<ApiResult<List<ChapterHadith>>> search(HadithSearchFilters filters);
}
