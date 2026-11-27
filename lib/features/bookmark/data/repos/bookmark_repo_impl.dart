import 'dart:developer';

import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/cache_fallback.dart';
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
  Future<ApiResult<List<UserBookmark>>> getBookmarks() => _cacheService
      .fetchWithStaleFallback<BookmarksResponse, List<UserBookmark>>(
        key: CacheKeys.bookmarks,
        fetch: () async {
          final token = await _tokenStorage.requireToken();
          return _apiService.getUserBookmarks(token);
        },
        toJson: (d) => d.toJson(),
        fromJson: BookmarksResponse.fromJson,
        toEntity:
            (d) => [
              for (final bookmark in d.bookmarks ?? const <Bookmark>[])
                bookmark.toEntity(),
            ],
        cacheExpirationHours: 1,
      );

  @override
  Future<List<BookmarkCollection>?> getCachedCollections() async {
    final cached = await _cacheService.getData<CollectionsResponse>(
      key: CacheKeys.bookmarkCollections,
      fromJson: CollectionsResponse.fromJson,
    );
    return cached?.toEntities();
  }

  @override
  Future<ApiResult<List<BookmarkCollection>>> getCollections() => _cacheService
      .fetchWithStaleFallback<CollectionsResponse, List<BookmarkCollection>>(
        key: CacheKeys.bookmarkCollections,
        fetch: () async {
          final token = await _tokenStorage.requireToken();
          return _apiService.getBookmarkCollection(token);
        },
        toJson: (d) => d.toJson(),
        fromJson: CollectionsResponse.fromJson,
        toEntity: (d) => d.toEntities(),
        cacheExpirationHours: 1,
      );

  @override
  Future<ApiResult<BookmarkActionResult>> addBookmark(
    UserBookmark bookmark,
  ) async {
    try {
      final token = await _tokenStorage.requireToken();
      final response = await _apiService.addBookmark(token, bookmark.toModel());
      await _forgetDerivedCaches();
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
      await _forgetDerivedCaches();
      return ApiResult.success(response.toEntity());
    } catch (error) {
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }

  /// The list, the collection counts and the bookmark stats all change with
  /// a bookmark, and offline would otherwise show them as they were before.
  Future<void> _forgetDerivedCaches() async {
    await _cacheService.clearCache(CacheKeys.bookmarks);
    await _cacheService.clearCache(CacheKeys.bookmarkCollections);
    await _cacheService.clearCache(CacheKeys.userStats);
  }
}
