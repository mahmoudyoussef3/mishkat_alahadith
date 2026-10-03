import 'package:mishkat_almasabih/core/domain/entities/chapter_hadith.dart';
import '../entities/hadith_search_filters.dart';
import '../repos/search_with_filters_repo.dart';

class GetCachedFilteredSearchUseCase {
  final SearchWithFiltersRepo _repo;

  GetCachedFilteredSearchUseCase(this._repo);

  Future<List<ChapterHadith>?> call(HadithSearchFilters filters) =>
      _repo.getCachedResults(filters);
}
