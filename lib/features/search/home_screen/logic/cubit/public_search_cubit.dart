import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/search/home_screen/data/models/public_search_model.dart';
import 'package:mishkat_almasabih/features/search/home_screen/data/repos/public_search_repo.dart';

part 'public_search_state.dart';

class PublicSearchCubit extends Cubit<PublicSearchState> {
  final PublicSearchRepo _publicSearchRepo;
  PublicSearchCubit(this._publicSearchRepo) : super(PublicSearchInitial());

  Future<void> emitPublicSearch(String query) async {
    log('🔍 [SearchCubit] Searching: "$query"');

    // Try cache first
    final cached = await _publicSearchRepo.getCachedSearch(query);

    if (cached != null) {
      log('✅ [SearchCubit] CACHE HIT - ${cached.search?.results?.data?.length ?? 0} results');
      // Emit cached data immediately
      emit(PublicSearchSuccess(cached, isFromCache: true, isRefreshing: true));

      // Background refresh
      _backgroundRefresh(query, cached);
    } else {
      log('❌ [SearchCubit] CACHE MISS - Fetching from API');
      // No cache, fetch from API
      emit(PublicSearchLoading());
      final result = await _publicSearchRepo.getPublicSearchRepo(query);
      result.fold(
        (error) {
          log('🔴 [SearchCubit] API ERROR: ${error.getAllErrorMessages()}');
          emit(PublicSearchFailure(error.getAllErrorMessages()));
        },
        (searchResult) {
          log('🟢 [SearchCubit] API SUCCESS - ${searchResult.search?.results?.data?.length ?? 0} results');
          emit(PublicSearchSuccess(searchResult));
        },
      );
    }
  }

  Future<void> _backgroundRefresh(String query, SearchResponse cached) async {
    log('🔄 [SearchCubit] Background refresh for: "$query"');
    final result = await _publicSearchRepo.getPublicSearchRepo(query);
    result.fold(
      (error) {
        log('⚠️ [SearchCubit] Background refresh FAILED: ${error.getAllErrorMessages()}');
        // Background refresh failed, keep cached data
        if (state is PublicSearchSuccess) {
          emit((state as PublicSearchSuccess).copyWith(isRefreshing: false));
        }
      },
      (searchResult) {
        log('🟢 [SearchCubit] Background refresh SUCCESS - ${searchResult.search?.results?.data?.length ?? 0} results');
        emit(
          PublicSearchSuccess(
            searchResult,
            isFromCache: false,
            isRefreshing: false,
          ),
        );
      },
    );
  }
}
