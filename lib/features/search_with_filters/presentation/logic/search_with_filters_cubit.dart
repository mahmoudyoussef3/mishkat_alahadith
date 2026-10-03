import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/search_with_filters/data/models/search_with_filters_model.dart';
import 'package:mishkat_almasabih/features/search_with_filters/data/repos/search_with_filters_repo.dart';
import 'package:mishkat_almasabih/core/networking/network_info.dart';

part 'search_with_filters_state.dart';

class SearchWithFiltersCubit extends Cubit<SearchWithFiltersState> {
  final SearchWithFiltersRepo _filtersRepo;
  final NetworkInfo _networkInfo;

  SearchWithFiltersCubit(this._filtersRepo, this._networkInfo) : super(SearchWithFiltersInitial());

  Future<void> emitSearchWithFilters({
    required String searchQuery,
    required String bookSlug,
    required String narrator,
    required String grade,
    required String chapterNumber,
    required String category,
  }) async {
    final cached = await _filtersRepo.getCachedSearchResults(
      searchQuery: searchQuery,
      bookSlug: bookSlug,
      narrator: narrator,
      grade: grade,
      chapter: chapterNumber,
      category: category,
    );

    if (cached != null) {
      emit(SearchWithFiltersSuccess(cached));
      return;
    }

    final hasInternet = await _networkInfo.isConnected;

    if (hasInternet) {
      emit(SearchWithFiltersLoading());
      _fetchFromServer(
        searchQuery: searchQuery,
        bookSlug: bookSlug,
        narrator: narrator,
        grade: grade,
        chapterNumber: chapterNumber,
        category: category,
      );
    } else {
      emit(SearchWithFiltersFailure('لا يوجد اتصال بالإنترنت'));
    }
  }

  Future<void> _fetchFromServer({
    required String searchQuery,
    required String bookSlug,
    required String narrator,
    required String grade,
    required String chapterNumber,
    required String category,
  }) async {
    final result = await _filtersRepo.searchWithFilters(
      searchQuery: searchQuery,
      bookSlug: bookSlug,
      narrator: narrator,
      grade: grade,
      chapter: chapterNumber,
      category: category,
    );
    result.fold(
      (l) => emit(SearchWithFiltersFailure(l.getAllErrorMessages())),
      (r) => emit(SearchWithFiltersSuccess(r)),
    );
  }
}
