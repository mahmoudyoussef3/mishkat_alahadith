import 'dart:developer';

import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';

import '../../domain/entities/book_chapter.dart';
import '../../domain/repos/chapters_repo.dart';
import '../mappers/chapters_mapper.dart';
import '../models/chapters_model.dart';

class ChaptersRepoImpl implements ChaptersRepo {
  final ApiService _apiService;
  final GenericCacheService _cacheService;

  ChaptersRepoImpl(this._apiService, this._cacheService);

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
}
