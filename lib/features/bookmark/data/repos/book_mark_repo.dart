import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/book_mark_model.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/book_mark_response.dart';
import 'package:mishkat_almasabih/features/bookmark/data/models/collection_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookMarkRepo {
  final ApiService _apiService;

  BookMarkRepo(this._apiService);

  /// Get all user bookmarks (with caching)
  Future<Either<ApiErrorModel, BookmarksResponse>> getUserBookMarks() async {
    try {
      final token = await _getUserToken();

      final response = await _apiService.getUserBookmarks(token);

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
