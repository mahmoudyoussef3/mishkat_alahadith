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
    // Try cache first
    final cached = await _publicSearchRepo.getCachedSearch(query);

    if (cached != null) {
      // Emit cached data immediately
      emit(PublicSearchSuccess(cached, isFromCache: true, isRefreshing: true));

      // Background refresh
      _backgroundRefresh(query, cached);
    } else {
      // No cache, fetch from API
      emit(PublicSearchLoading());
      final result = await _publicSearchRepo.getPublicSearchRepo(query);
      result.fold(
        (error) => emit(PublicSearchFailure(error.getAllErrorMessages())),
        (searchResult) => emit(PublicSearchSuccess(searchResult)),
      );
    }
  }

  Future<void> _backgroundRefresh(String query, SearchResponse cached) async {
    final result = await _publicSearchRepo.getPublicSearchRepo(query);
    result.fold(
      (error) {
        // Background refresh failed, keep cached data
        if (state is PublicSearchSuccess) {
          emit((state as PublicSearchSuccess).copyWith(isRefreshing: false));
        }
      },
      (searchResult) {
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
