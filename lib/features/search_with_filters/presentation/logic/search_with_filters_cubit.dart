import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/domain/entities/chapter_hadith.dart';
import 'package:mishkat_almasabih/features/search_with_filters/domain/entities/hadith_search_filters.dart';
import 'package:mishkat_almasabih/features/search_with_filters/domain/usecases/get_cached_filtered_search_use_case.dart';
import 'package:mishkat_almasabih/features/search_with_filters/domain/usecases/search_with_filters_use_case.dart';

part 'search_with_filters_state.dart';

class SearchWithFiltersCubit extends Cubit<SearchWithFiltersState> {
  final GetCachedFilteredSearchUseCase _getCachedResults;
  final SearchWithFiltersUseCase _search;

  SearchWithFiltersCubit(this._getCachedResults, this._search)
    : super(SearchWithFiltersInitial());

  Future<void> emitSearchWithFilters({
    required String searchQuery,
    required String bookSlug,
    required String narrator,
    required String grade,
    required String chapterNumber,
    required String category,
  }) async {
    final filters = HadithSearchFilters(
      query: searchQuery,
      bookSlug: bookSlug,
      narrator: narrator,
      grade: grade,
      chapter: chapterNumber,
      category: category,
    );

    final cached = await _getCachedResults(filters);
    if (cached != null) {
      emit(SearchWithFiltersSuccess(cached));
      return;
    }

    emit(SearchWithFiltersLoading());
    final result = await _search(filters);
    result.when(
      success: (results) => emit(SearchWithFiltersSuccess(results)),
      failure: (failure) => emit(SearchWithFiltersFailure(failure.message)),
    );
  }
}
