import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/features/search_with_filters/data/models/search_with_filters_model.dart';

class SearchWithFiltersRepo {
  final ApiService _apiService;
  final _cacheService = GenericCacheService.instance;

  SearchWithFiltersRepo(this._apiService);

  /// Get cached search results
  Future<SearchWithFiltersModel?> getCachedSearchResults({
    required String searchQuery,
    required String bookSlug,
    required String narrator,
    required String grade,
    required String chapter,
    required String category,
  }) async {
    final cacheKey = CacheKeys.searchWithFilters(
      searchQuery,
      bookSlug,
      narrator,
      grade,
      chapter,
      category,
    );
    return await _cacheService.getData<SearchWithFiltersModel>(
      key: cacheKey,
      fromJson: SearchWithFiltersModel.fromJson,
    );
  }

  /// Save search results to cache
  Future<void> cacheSearchResults({
    required String searchQuery,
    required String bookSlug,
    required String narrator,
    required String grade,
    required String chapter,
    required String category,
    required SearchWithFiltersModel data,
  }) async {
    final cacheKey = CacheKeys.searchWithFilters(
      searchQuery,
      bookSlug,
      narrator,
      grade,
      chapter,
      category,
    );
    await _cacheService.saveData<SearchWithFiltersModel>(
      key: cacheKey,
      data: data,
      toJson: (d) => d.toJson(),
      cacheExpirationHours: 6, // Cache search results for 6 hours
    );
  }

  Future<Either<ApiErrorModel, SearchWithFiltersModel>> searchWithFilters({
    required String searchQuery,
    required String bookSlug,
    required String narrator,
    required String grade,
    required String chapter,
    required String category
  }) async {
    try {
      final response = await _apiService.searchWithFilters(
        searchQuery,
        bookSlug,
        narrator,
        grade,
        chapter,
        category
      );

      // Cache the response
      await cacheSearchResults(
        searchQuery: searchQuery,
        bookSlug: bookSlug,
        narrator: narrator,
        grade: grade,
        chapter: chapter,
        category: category,
        data: response,
      );

      return Right(response);
    } catch (error) {
      return Left(ErrorHandler.handle(error));
    }
  }
}
