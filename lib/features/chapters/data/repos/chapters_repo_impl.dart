import 'dart:developer';

import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';

import '../../domain/entities/book_chapter.dart';
import '../../domain/entities/last_read_chapter.dart';
import '../../domain/repos/chapters_repo.dart';
import '../datasources/chapters_progress_local_datasource.dart';
import '../mappers/chapters_mapper.dart';
import '../models/chapters_model.dart';

class ChaptersRepoImpl implements ChaptersRepo {
  final ApiService _apiService;
  final GenericCacheService _cacheService;
  final ChaptersProgressLocalDataSource _progress;

  ChaptersRepoImpl(this._apiService, this._cacheService, this._progress);

  @override
  Future<List<BookChapter>?> getCachedChapters(String bookSlug) async {
    final cached = await _cacheService.getData<ChaptersModel>(
      key: CacheKeys.chapters(bookSlug),
      fromJson: ChaptersModel.fromJson,
    );
    return cached?.toEntities();
  }

  @override
  Future<ApiResult<List<BookChapter>>> getChapters(String bookSlug) async {
    try {
      final response = await _apiService.getBookChapters(bookSlug);
      await _cacheService.saveData<ChaptersModel>(
        key: CacheKeys.chapters(bookSlug),
        data: response,
        toJson: (d) => d.toJson(),
        cacheExpirationHours: 24,
      );
      return ApiResult.success(response.toEntities());
    } catch (error) {
      log(error.toString());
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }

  @override
  Future<ApiResult<LastReadChapter?>> getLastReadChapter(
    String bookSlug,
  ) async {
    try {
      final json = await _progress.getLastReadChapter(bookSlug);
      final number = json?['chapterNumber'];
      final title = json?['title'];
      if (number is! int || title is! String) {
        return const ApiResult.success(null);
      }
      return ApiResult.success(
        LastReadChapter(chapterNumber: number, title: title),
      );
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }

  @override
  Future<ApiResult<void>> saveLastReadChapter(
    String bookSlug,
    LastReadChapter chapter,
  ) async {
    try {
      await _progress.saveLastReadChapter(bookSlug, {
        'chapterNumber': chapter.chapterNumber,
        'title': chapter.title,
      });
      return const ApiResult.success(null);
    } catch (_) {
      return const ApiResult.failure(CacheFailure());
    }
  }
}
