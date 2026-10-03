import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/features/navigation/data/models/local_hadith_navigation_model.dart';
import 'package:mishkat_almasabih/features/navigation/data/models/navigation_hadith_model.dart';

class NavigationRepo {
  final ApiService _apiService;
  final _cacheService = GenericCacheService.instance;

  NavigationRepo(this._apiService);

  /// Get cached navigation data
  Future<NavigationHadithResponse?> getCachedNavigation(
    String bookSlug,
    int chapterNumber,
    String hadithNumber,
  ) async {
    final cacheKey = CacheKeys.navigation(
      bookSlug,
      chapterNumber,
      hadithNumber,
    );
    return await _cacheService.getData<NavigationHadithResponse>(
      key: cacheKey,
      fromJson: NavigationHadithResponse.fromJson,
    );
  }

  /// Save navigation data to cache
  Future<void> cacheNavigation(
    String bookSlug,
    int chapterNumber,
    String hadithNumber,
    NavigationHadithResponse data,
  ) async {
    final cacheKey = CacheKeys.navigation(
      bookSlug,
      chapterNumber,
      hadithNumber,
    );
    await _cacheService.saveData<NavigationHadithResponse>(
      key: cacheKey,
      data: data,
      toJson: (d) => d.toJson(),
      cacheExpirationHours: 24,
    );
  }

  Future<Either<ApiErrorModel, NavigationHadithResponse>> navigationHadith(
    String hadithNumber,
    String bookSlug,
    String chapterNumber,
  ) async {
    try {
      final response = await _apiService.navigationHadith(
        hadithNumber,
        bookSlug,
        chapterNumber,
      );
      // Cache the response
      await cacheNavigation(
        bookSlug,
        int.tryParse(chapterNumber) ?? 0,
        hadithNumber,
        response,
      );
      return Right(response);
    } catch (err) {
      log(err.toString());
      return Left(ErrorHandler.handle(err));
    }
  }

  Future<Either<ApiErrorModel, LocalNavigationHadithResponse>> localNavigation(
    String hadithNumber,
    String bookSlug,
  ) async {
    try {
      final response = await _apiService.localNavigationHadith(
        hadithNumber,
        bookSlug,
      );
      return Right(response);
    } catch (err) {
      log(err.toString());
      return Left(ErrorHandler.handle(err));
    }
  }
}
