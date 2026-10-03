import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';

import '../../domain/entities/search_history_entry.dart';
import '../../domain/repos/search_history_repo.dart';
import '../mappers/search_history_mapper.dart';

class SearchHistoryRepoImpl implements SearchHistoryRepo {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;

  SearchHistoryRepoImpl(this._apiService, this._tokenStorage);

  @override
  Future<ApiResult<List<SearchHistoryEntry>>> getHistory() async {
    try {
      final token = await _tokenStorage.requireToken();
      final response = await _apiService.getSearchHistory(token);
      return ApiResult.success(response.data.map((e) => e.toEntity()).toList());
    } catch (error) {
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }

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
      return const ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }
}
