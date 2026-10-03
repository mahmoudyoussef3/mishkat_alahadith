import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/data/models/enhanced_search_response_model.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/data/repos/enhanced_search_repo.dart';
import 'package:mishkat_almasabih/core/networking/network_info.dart';

part 'enhanced_search_state.dart';

class EnhancedSearchCubit extends Cubit<EnhancedSearchState> {
  final EnhancedSearchRepo enhancedSearchRepo;
  final NetworkInfo _networkInfo;

  EnhancedSearchCubit(this.enhancedSearchRepo, this._networkInfo) : super(EnhancedSearchInitial());

  Future<void> fetchEnhancedSearchResults(String searchTerm) async {
    final cached = await enhancedSearchRepo.getCachedSearch(searchTerm);

    if (cached != null) {
      emit(EnhancedSearchLoaded(cached, isFromCache: true, isRefreshing: false));
      return;
    }

    final hasInternet = await _networkInfo.isConnected;

    if (hasInternet) {
      emit(EnhancedSearchLoading());
      _fetchFromServer(searchTerm);
    } else {
      emit(EnhancedSearchError('لا يوجد اتصال بالإنترنت'));
    }
  }

  Future<void> _fetchFromServer(String searchTerm) async {
    final result = await enhancedSearchRepo.fetchEnhancedSearchResults(
      searchTerm,
    );
    result.fold(
      (error) => emit(EnhancedSearchError(error.getAllErrorMessages())),
      (enhancedSearch) => emit(EnhancedSearchLoaded(enhancedSearch)),
    );
  }
}
