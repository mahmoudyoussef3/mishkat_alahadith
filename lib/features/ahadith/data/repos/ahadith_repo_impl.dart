import 'dart:developer';

import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';

import '../../domain/entities/chapter_ahadith_page.dart';
import 'package:mishkat_almasabih/core/domain/entities/chapter_hadith.dart';
import '../../domain/entities/local_book_hadith.dart';
import '../../domain/repos/ahadith_repo.dart';
import '../mappers/ahadith_mapper.dart';
import '../models/ahadiths_model.dart';
import '../models/cached_ahadith_data.dart';

class AhadithRepoImpl implements AhadithRepo {
  final ApiService _apiService;
  final GenericCacheService _cacheService;

  AhadithRepoImpl(this._apiService, this._cacheService);

  @override
  Future<CachedChapterAhadith?> getCachedAhadith({
    required String bookSlug,
    required int chapterId,
  }) async {
    final cached = await _cacheService.getData<CachedAhadithData>(
      key: CacheKeys.paginatedAhadith(bookSlug, chapterId),
      fromJson: CachedAhadithData.fromJson,
    );
    if (cached == null) return null;
    return CachedChapterAhadith(
      ahadith: cached.ahadith.map((h) => h.toEntity()).toList(),
      lastLoadedPage: cached.lastPage,
      totalCount: cached.totalCount,
    );
  }

  @override
  Future<void> cacheAhadith({
    required String bookSlug,
    required int chapterId,
    required List<ChapterHadith> ahadith,
    required int lastLoadedPage,
    required int totalCount,
  }) async {
    await _cacheService.saveData<CachedAhadithData>(
      key: CacheKeys.paginatedAhadith(bookSlug, chapterId),
      data: CachedAhadithData(
        ahadith: ahadith.map((h) => h.toModel()).toList(),
        lastPage: lastLoadedPage,
        totalCount: totalCount,
        cachedAt: DateTime.now(),
      ),
      toJson: (d) => d.toJson(),
      cacheExpirationHours: 24,
    );
  }

  @override
  Future<ApiResult<ChapterAhadithPage>> getAhadithPage({
    required String bookSlug,
    required int chapterId,
    required int page,
    required int paginate,
  }) async {
    try {
      final response = await _apiService.getChapterAhadiths(
        bookSlug,
        chapterId,
        page,
        paginate,
      );
      return ApiResult.success(
        ChapterAhadithPage(
          ahadith: [
            for (final hadith in response.hadiths?.data ?? const <Hadith>[])
              hadith.toEntity(),
          ],
          totalPages: response.hadiths?.last_page ?? 1,
          total: response.hadiths?.total ?? 0,
        ),
      );
    } catch (error) {
      log(error.toString());
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }

  @override
  Future<ApiResult<List<LocalBookHadith>>> getLocalAhadith({
    required String bookSlug,
    required int chapterId,
  }) async {
    try {
      final response = await _apiService.getLocalChapterAhadiths(
        bookSlug,
        chapterId,
      );
      return ApiResult.success(response.toEntities());
    } catch (error) {
      log(error.toString());
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }

  @override
  Future<ApiResult<List<LocalBookHadith>>> getArbainAhadith({
    required String bookSlug,
    required int chapterId,
  }) async {
    try {
      final response = await _apiService.getThreeBooksLocalChapterAhadiths(
        bookSlug,
        chapterId,
      );
      return ApiResult.success(response.toEntities());
    } catch (error) {
      log(error.toString());
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }
}
