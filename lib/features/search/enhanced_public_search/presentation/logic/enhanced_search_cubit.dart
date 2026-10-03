import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/domain/usecases/enhanced_search_use_case.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/domain/usecases/get_cached_enhanced_search_use_case.dart';

part 'enhanced_search_state.dart';

class EnhancedSearchCubit extends Cubit<EnhancedSearchState> {
  final GetCachedEnhancedSearchUseCase _getCachedResults;
  final EnhancedSearchUseCase _search;

  EnhancedSearchCubit(this._getCachedResults, this._search)
    : super(EnhancedSearchInitial());

  Future<void> fetchEnhancedSearchResults(String searchTerm) async {
    final cached = await _getCachedResults(searchTerm);

    if (cached != null) {
      emit(
        EnhancedSearchLoaded(cached, isFromCache: true, isRefreshing: false),
      );
      return;
    }

    emit(EnhancedSearchLoading());
    final result = await _search(searchTerm);
    result.when(
      success: (results) => emit(EnhancedSearchLoaded(results)),
      failure: (failure) => emit(EnhancedSearchError(failure.message)),
    );
  }
}
