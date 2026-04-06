import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/features/search/home_screen/data/models/public_search_model.dart';

class PublicSearchRepo {
  final ApiService _apiService;
  final _cacheService = GenericCacheService.instance;

  PublicSearchRepo(this._apiService);

  /// Get cached search results
  Future<SearchResponse?> getCachedSearch(String query) async {
    final cacheKey = CacheKeys.search(query);
    return await _cacheService.getData<SearchResponse>(
      key: cacheKey,
      fromJson: SearchResponse.fromJson,
    );
  }

  /// Save search results to cache
  Future<void> cacheSearch(String query, SearchResponse data) async {
    final cacheKey = CacheKeys.search(query);
    await _cacheService.saveData<SearchResponse>(
      key: cacheKey,
      data: data,
      toJson: (d) => d.toJson(),
      cacheExpirationHours: 6, // Shorter cache for search
    );
  }

  Future<Either<ApiErrorModel, SearchResponse>> getPublicSearchRepo(
    String query,
  ) async {
    try {
      final response = await _apiService.getpublicSearch(query);
      // Cache the response
      await cacheSearch(query, response);
      return Right(response);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }
}
