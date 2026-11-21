import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/cache_fallback.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';

import '../../domain/entities/category_books.dart';
import '../../domain/entities/library_statistics.dart';
import '../../domain/repos/library_repo.dart';
import '../mappers/library_mapper.dart';
import '../models/book_data_model.dart';
import '../models/library_statistics_model.dart';

class LibraryRepoImpl implements LibraryRepo {
  final ApiService _apiService;
  final GenericCacheService _cacheService;

  LibraryRepoImpl(this._apiService, this._cacheService);

  @override
  Future<CategoryBooks?> getCachedCategoryBooks(String categoryId) async {
    final cached = await _cacheService.getData<CategoryResponse>(
      key: CacheKeys.bookData(categoryId),
      fromJson: CategoryResponse.fromJson,
    );
    return cached?.toEntity();
  }

  @override
  Future<ApiResult<CategoryBooks>> getCategoryBooks(String categoryId) =>
      _cacheService.fetchWithStaleFallback<CategoryResponse, CategoryBooks>(
        key: CacheKeys.bookData(categoryId),
        fetch: () => _apiService.getBookData(categoryId),
        toJson: (d) => d.toJson(),
        fromJson: CategoryResponse.fromJson,
        toEntity: (d) => d.toEntity(),
      );

  @override
  Future<LibraryStatistics?> getCachedStatistics() async {
    final cached = await _cacheService.getData<StatisticsResponse>(
      key: CacheKeys.libraryStatistics,
      fromJson: StatisticsResponse.fromJson,
    );
    return cached?.toEntity();
  }

  @override
  Future<ApiResult<LibraryStatistics>> getStatistics() => _cacheService
      .fetchWithStaleFallback<StatisticsResponse, LibraryStatistics>(
        key: CacheKeys.libraryStatistics,
        fetch: _apiService.getLibraryStatisctics,
        toJson: (d) => d.toJson(),
        fromJson: StatisticsResponse.fromJson,
        toEntity: (d) => d.toEntity(),
      );
}
