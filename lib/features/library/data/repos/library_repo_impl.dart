import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/features/book_data/data/models/book_data_model.dart';

class GetBookDataRepo {
  final ApiService _apiService;
  final _cacheService = GenericCacheService.instance;

  GetBookDataRepo(this._apiService);

  /// Get cached book data
  Future<CategoryResponse?> getCachedBookData(String id) async {
    final cacheKey = CacheKeys.bookData(id);
    return await _cacheService.getData<CategoryResponse>(
      key: cacheKey,
      fromJson: CategoryResponse.fromJson,
    );
  }

  /// Save book data to cache
  Future<void> cacheBookData(String id, CategoryResponse data) async {
    final cacheKey = CacheKeys.bookData(id);
    await _cacheService.saveData<CategoryResponse>(
      key: cacheKey,
      data: data,
      toJson: (d) => d.toJson(),
      cacheExpirationHours: 24,
    );
  }

  Future<Either<ApiErrorModel, CategoryResponse>> getBookData(String id) async {
    try {
      final response = await _apiService.getBookData(id);
      // Cache the response
      await cacheBookData(id, response);
      log('🌍 Loaded BookData from API and cached it for $id');
      return Right(response);
    } catch (error) {
      log(error.toString());
      return Left(ErrorHandler.handle(error));
    }
  }
}
