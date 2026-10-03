import 'dart:developer';

import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';

import '../../domain/entities/bookmark_action_result.dart';
import '../../domain/entities/bookmark_collection.dart';
import '../../domain/entities/user_bookmark.dart';
import '../../domain/repos/bookmark_repo.dart';
import '../mappers/bookmark_mapper.dart';
import '../models/book_mark_model.dart';
import '../models/collection_model.dart';

class BookmarkRepoImpl implements BookmarkRepo {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;
  final GenericCacheService _cacheService;

  BookmarkRepoImpl(this._apiService, this._tokenStorage, this._cacheService);

  @override
  Future<List<UserBookmark>?> getCachedBookmarks() async {
    final cached = await _cacheService.getData<BookmarksResponse>(
      key: CacheKeys.bookmarks,
      fromJson: BookmarksResponse.fromJson,
    );
    return cached?.bookmarks?.map((b) => b.toEntity()).toList();
  }

  @override
  Future<ApiResult<List<UserBookmark>>> getBookmarks() async {
    try {
      final token = await _tokenStorage.requireToken();
      final response = await _apiService.getUserBookmarks(token);
      await _cacheService.saveData<BookmarksResponse>(
        key: CacheKeys.bookmarks,
        data: response,
        toJson: (d) => d.toJson(),
        cacheExpirationHours: 1,
      );
      return ApiResult.success([
        for (final bookmark in response.bookmarks ?? const <Bookmark>[])
          bookmark.toEntity(),
      ]);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }

  @override
  Future<List<BookmarkCollection>?> getCachedCollections() async {
    final cached = await _cacheService.getData<CollectionsResponse>(
      key: CacheKeys.bookmarkCollections,
      fromJson: CollectionsResponse.fromJson,
    );
    return cached?.toEntities();
  }

  @override
  Future<ApiResult<List<BookmarkCollection>>> getCollections() async {
    try {
      final token = await _tokenStorage.requireToken();
      final response = await _apiService.getBookmarkCollection(token);
      await _cacheService.saveData<CollectionsResponse>(
        key: CacheKeys.bookmarkCollections,
        data: response,
        toJson: (d) => d.toJson(),
        cacheExpirationHours: 1,
      );
      return ApiResult.success(response.toEntities());
    } catch (error) {
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }

  @override
  Future<ApiResult<BookmarkActionResult>> addBookmark(
    UserBookmark bookmark,
  ) async {
    try {
      final token = await _tokenStorage.requireToken();
      final response = await _apiService.addBookmark(token, bookmark.toModel());
      await _cacheService.clearCache(CacheKeys.bookmarks);
      return ApiResult.success(response.toEntity());
    } catch (error) {
      log(error.toString());
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }

  @override
  Future<ApiResult<BookmarkActionResult>> deleteBookmark(int bookmarkId) async {
    try {
      final token = await _tokenStorage.requireToken();
      final response = await _apiService.deleteUserBookmsrk(bookmarkId, token);
      await _cacheService.clearCache(CacheKeys.bookmarks);
      return ApiResult.success(response.toEntity());
    } catch (error) {
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }
}
