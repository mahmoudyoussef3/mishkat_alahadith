import 'dart:developer';

import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';

import '../../domain/entities/hadith_navigation.dart';
import '../../domain/repos/navigation_repo.dart';
import '../mappers/navigation_mapper.dart';
import '../models/navigation_hadith_model.dart';

class NavigationRepoImpl implements NavigationRepo {
  final ApiService _apiService;
  final GenericCacheService _cacheService;

  NavigationRepoImpl(this._apiService, this._cacheService);

  String _cacheKey(
    String bookSlug,
    String chapterNumber,
    String hadithNumber,
  ) => CacheKeys.navigation(
    bookSlug,
    int.tryParse(chapterNumber) ?? 0,
    hadithNumber,
  );

  @override
  Future<HadithNavigation?> getCachedNavigation({
    required String hadithNumber,
    required String bookSlug,
    required String chapterNumber,
  }) async {
    final cached = await _cacheService.getData<NavigationHadithResponse>(
      key: _cacheKey(bookSlug, chapterNumber, hadithNumber),
      fromJson: NavigationHadithResponse.fromJson,
    );
    return cached?.toEntity();
  }

  @override
  Future<ApiResult<HadithNavigation>> getNavigation({
    required String hadithNumber,
    required String bookSlug,
    required String chapterNumber,
  }) async {
    try {
      final response = await _apiService.navigationHadith(
        hadithNumber,
        bookSlug,
        chapterNumber,
      );
      await _cacheService.saveData<NavigationHadithResponse>(
        key: _cacheKey(bookSlug, chapterNumber, hadithNumber),
        data: response,
        toJson: (d) => d.toJson(),
        cacheExpirationHours: 24,
      );
      return ApiResult.success(response.toEntity());
    } catch (error) {
      log(error.toString());
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }

  @override
  Future<ApiResult<HadithNavigation>> getLocalNavigation({
    required String hadithNumber,
    required String bookSlug,
  }) async {
    try {
      final response = await _apiService.localNavigationHadith(
        hadithNumber,
        bookSlug,
      );
      return ApiResult.success(response.toEntity());
    } catch (error) {
      log(error.toString());
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }
}
