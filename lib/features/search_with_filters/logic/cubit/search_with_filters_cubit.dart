import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/search_with_filters/data/models/search_with_filters_model.dart';
import 'package:mishkat_almasabih/features/search_with_filters/data/repos/search_with_filters_repo.dart';

part 'search_with_filters_state.dart';

class SearchWithFiltersCubit extends Cubit<SearchWithFiltersState> {
  final SearchWithFiltersRepo _filtersRepo;
  SearchWithFiltersCubit(this._filtersRepo) : super(SearchWithFiltersInitial());

  Future<void> emitSearchWithFilters({
    required String searchQuery,
    required String bookSlug,
    required String narrator,
    required String grade,
    required String chapterNumber,
    required String category,
  }) async {
    emit(SearchWithFiltersLoading());
    final result = await _filtersRepo.searchWithFilters(
      searchQuery: searchQuery,
      bookSlug: bookSlug,
      narrator: narrator,
      grade: grade,
      chapter: chapterNumber,
      category: category,
    );
    result.fold(
      (l) => emit(
        SearchWithFiltersFailure(
          l.getAllErrorMessages() ,
        ),
      ),
      (r) => emit(SearchWithFiltersSuccess(r)),
    );
  }
}
