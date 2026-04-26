import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/data/models/enhanced_search_response_model.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/data/repos/enhanced_search_repo.dart';

part 'enhanced_search_state.dart';

class EnhancedSearchCubit extends Cubit<EnhancedSearchState> {
  final EnhancedSearchRepo enhancedSearchRepo;
  EnhancedSearchCubit(this.enhancedSearchRepo) : super(EnhancedSearchInitial());

  Future<void> fetchEnhancedSearchResults(String searchTerm) async {
    // Try cache first
    final cached = await enhancedSearchRepo.getCachedSearch(searchTerm);

    if (cached != null) {
      // Emit cached data immediately
      emit(EnhancedSearchLoaded(cached, isFromCache: true, isRefreshing: true));

      // Background refresh
      _backgroundRefresh(searchTerm, cached);
    } else {
      // No cache, fetch from API
      emit(EnhancedSearchLoading());
      final result = await enhancedSearchRepo.fetchEnhancedSearchResults(
        searchTerm,
      );
      result.fold(
        (error) => emit(EnhancedSearchError(error.getAllErrorMessages())),
        (enhancedSearch) => emit(EnhancedSearchLoaded(enhancedSearch)),
      );
    }
  }

  Future<void> _backgroundRefresh(
    String searchTerm,
    EnhancedSearch cached,
  ) async {
    final result = await enhancedSearchRepo.fetchEnhancedSearchResults(
      searchTerm,
    );
    result.fold(
      (error) {
        // Background refresh failed, keep cached data
        if (state is EnhancedSearchLoaded) {
          emit((state as EnhancedSearchLoaded).copyWith(isRefreshing: false));
        }
      },
      (enhancedSearch) {
        emit(
          EnhancedSearchLoaded(
            enhancedSearch,
            isFromCache: false,
            isRefreshing: false,
          ),
        );
      },
    );
  }
}
