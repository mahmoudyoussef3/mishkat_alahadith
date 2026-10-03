import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/book_mark_model.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/book_mark_response.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/collection_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookMarkRepo {
  final ApiService _apiService;
  final _cacheService = GenericCacheService.instance;

  BookMarkRepo(this._apiService);

  /// Get cached bookmarks
  Future<BookmarksResponse?> getCachedBookmarks() async {
    return await _cacheService.getData<BookmarksResponse>(
      key: CacheKeys.bookmarks,
      fromJson: BookmarksResponse.fromJson,
    );
  }

  /// Save bookmarks to cache
  Future<void> cacheBookmarks(BookmarksResponse data) async {
    await _cacheService.saveData<BookmarksResponse>(
      key: CacheKeys.bookmarks,
      data: data,
      toJson: (d) => d.toJson(),
      cacheExpirationHours: 1,
    );
  }

  /// Get cached collections
  Future<CollectionsResponse?> getCachedCollections() async {
    return await _cacheService.getData<CollectionsResponse>(
      key: CacheKeys.bookmarkCollections,
      fromJson: CollectionsResponse.fromJson,
    );
  }

  /// Save collections to cache
  Future<void> cacheCollections(CollectionsResponse data) async {
    await _cacheService.saveData<CollectionsResponse>(
      key: CacheKeys.bookmarkCollections,
      data: data,
      toJson: (d) => d.toJson(),
      cacheExpirationHours: 1,
    );
  }

  /// Invalidate bookmarks cache (call after add/delete)
  Future<void> invalidateBookmarksCache() async {
    await _cacheService.clearCache(CacheKeys.bookmarks);
  }

  /// Get all user bookmarks (with caching)
  Future<Either<ApiErrorModel, BookmarksResponse>> getUserBookMarks() async {
    try {
      final token = await _getUserToken();
      final response = await _apiService.getUserBookmarks(token);
      // Cache the response
      await cacheBookmarks(response);
      return Right(response);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<ApiErrorModel, CollectionsResponse>>
  getBookmarkCollectionsRepo() async {
    try {
      final token = await _getUserToken();
      final response = await _apiService.getBookmarkCollection(token);
      // Cache the response
      await cacheCollections(response);
      return Right(response);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<ApiErrorModel, AddBookmarkResponse>> deleteBookMark(
    int bookmarkId,
  ) async {
    try {
      final token = await _getUserToken();
      final response = await _apiService.deleteUserBookmsrk(bookmarkId, token);
      // Invalidate cache after mutation
      await invalidateBookmarksCache();
      return Right(response);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<ApiErrorModel, AddBookmarkResponse>> addBookmark(
    Bookmark body,
  ) async {
    try {
      final token = await _getUserToken();
      final response = await _apiService.addBookmark(token, body);
      // Invalidate cache after mutation
      await invalidateBookmarksCache();
      return Right(response);
    } catch (e) {
      log(e.toString());
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<String> _getUserToken() async {
    final sharedPref = await SharedPreferences.getInstance();
    final token = sharedPref.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception("No token found, user not logged in");
    }
    return token;
  }
}
