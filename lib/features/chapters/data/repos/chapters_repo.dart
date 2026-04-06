import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/features/chapters/data/models/chapters_model.dart';

class BookChaptersRepo {
  final ApiService _apiService;
  final _cacheService = GenericCacheService.instance;

  BookChaptersRepo(this._apiService);

  /// Get cached chapters for a book
  Future<ChaptersModel?> getCachedChapters(String bookSlug) async {
    final cacheKey = CacheKeys.chapters(bookSlug);
    return await _cacheService.getData<ChaptersModel>(
      key: cacheKey,
      fromJson: ChaptersModel.fromJson,
    );
  }

  /// Save chapters to cache
  Future<void> cacheChapters(String bookSlug, ChaptersModel data) async {
    final cacheKey = CacheKeys.chapters(bookSlug);
    await _cacheService.saveData<ChaptersModel>(
      key: cacheKey,
      data: data,
      toJson: (d) => d.toJson(),
      cacheExpirationHours: 24,
    );
  }

  Future<Either<ApiErrorModel, ChaptersModel>> getBookChapters(
    String bookSlug,
  ) async {
    try {
      final response = await _apiService.getBookChapters(bookSlug);
      // Cache the response
      await cacheChapters(bookSlug, response);
      return Right(response);
    } catch (error) {
      log(error.toString());
      return Left(ErrorHandler.handle(error));
    }
  }
}
