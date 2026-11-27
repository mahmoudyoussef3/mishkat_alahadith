import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/cache_fallback.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';

import '../../domain/entities/search_history_entry.dart';
import '../../domain/repos/search_history_repo.dart';
import '../mappers/search_history_mapper.dart';
import '../models/search_history_models.dart';

class SearchHistoryRepoImpl implements SearchHistoryRepo {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;
  final GenericCacheService _cacheService;

  SearchHistoryRepoImpl(
    this._apiService,
    this._tokenStorage,
    this._cacheService,
  );

  @override
  Future<ApiResult<List<SearchHistoryEntry>>> getHistory() =>
      _cacheService.fetchWithStaleFallback<
        GetSearchHistoryResponse,
        List<SearchHistoryEntry>
      >(
        key: CacheKeys.searchHistory,
        fetch: () async {
          final token = await _tokenStorage.requireToken();
          return _apiService.getSearchHistory(token);
        },
        toJson: (d) => d.toJson(),
        fromJson: GetSearchHistoryResponse.fromJson,
        toEntity: (d) => d.data.map((e) => e.toEntity()).toList(),
        cacheExpirationHours: 1,
      );

  /// Once entries are deleted the kept history would show them again
  /// offline, so it is dropped. A new search only leaves it one entry
  /// behind, which is ordinary staleness and is kept.
  Future<void> _forgetCachedHistory() =>
      _cacheService.clearCache(CacheKeys.searchHistory);

  @override
  Future<ApiResult<void>> addEntry(NewSearchHistoryEntry entry) async {
    try {
      final token = await _tokenStorage.requireToken();
      await _apiService.addSearch(token, entry.toRequest());
      return const ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }

  @override
  Future<ApiResult<void>> deleteEntry(int id) async {
    try {
      final token = await _tokenStorage.requireToken();
      await _apiService.deleteSearch(token, id);
      await _forgetCachedHistory();
      return const ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }

  @override
  Future<ApiResult<void>> clearHistory() async {
    try {
      final token = await _tokenStorage.requireToken();
      await _apiService.deleteAllSearch(token, {"confirm": true});
      await _forgetCachedHistory();
      return const ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }
}
