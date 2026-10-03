import 'package:mishkat_almasabih/core/networking/api_result.dart';

import 'package:mishkat_almasabih/core/domain/entities/chapter_hadith.dart';
import '../entities/hadith_search_filters.dart';
import '../repos/search_with_filters_repo.dart';

class SearchWithFiltersUseCase {
  final SearchWithFiltersRepo _repo;

  SearchWithFiltersUseCase(this._repo);

  Future<ApiResult<List<ChapterHadith>>> call(HadithSearchFilters filters) =>
      _repo.search(filters);
}
