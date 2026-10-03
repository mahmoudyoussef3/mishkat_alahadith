import 'dart:developer';

import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
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
  Future<ApiResult<CategoryBooks>> getCategoryBooks(String categoryId) async {
    try {
      final response = await _apiService.getBookData(categoryId);
      await _cacheService.saveData<CategoryResponse>(
        key: CacheKeys.bookData(categoryId),
        data: response,
        toJson: (d) => d.toJson(),
        cacheExpirationHours: 24,
      );
      log('🌍 Loaded BookData from API and cached it for $categoryId');
      return ApiResult.success(response.toEntity());
    } catch (error) {
      log(error.toString());
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }

  @override
  Future<LibraryStatistics?> getCachedStatistics() async {
    final cached = await _cacheService.getData<StatisticsResponse>(
      key: CacheKeys.libraryStatistics,
      fromJson: StatisticsResponse.fromJson,
    );
    return cached?.toEntity();
  }

  @override
  Future<ApiResult<LibraryStatistics>> getStatistics() async {
    try {
      final response = await _apiService.getLibraryStatisctics();
      await _cacheService.saveData<StatisticsResponse>(
        key: CacheKeys.libraryStatistics,
        data: response,
        toJson: (d) => d.toJson(),
        cacheExpirationHours: 24,
      );
      return ApiResult.success(response.toEntity());
    } catch (error) {
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }
}
