import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/data/models/enhanced_search_response_model.dart';

class EnhancedSearchRepo {
  final ApiService _apiService;
  final _cacheService = GenericCacheService.instance;

  EnhancedSearchRepo(this._apiService);

  /// Get cached enhanced search results
  Future<EnhancedSearch?> getCachedSearch(String searchTerm) async {
    final cacheKey = CacheKeys.enhancedSearch(searchTerm);
    return await _cacheService.getData<EnhancedSearch>(
      key: cacheKey,
      fromJson: EnhancedSearch.fromJson,
    );
  }

  /// Save enhanced search results to cache
  Future<void> cacheSearch(String searchTerm, EnhancedSearch data) async {
    final cacheKey = CacheKeys.enhancedSearch(searchTerm);
    await _cacheService.saveData<EnhancedSearch>(
      key: cacheKey,
      data: data,
      toJson: (d) => d.toJson(),
      cacheExpirationHours: 6,
    );
  }

  Future<Either<ApiErrorModel, EnhancedSearch>> fetchEnhancedSearchResults(
    String searchTerm,
  ) async {
    try {
      final response = await _apiService.getEnhancedSearch({
        "searchTerm": searchTerm,
      });
      // Cache the response
      await cacheSearch(searchTerm, response);
      return Right(response);
    } catch (e) {
      return Left(ErrorHandler.handle(e.toString()));
    }
  }
}
