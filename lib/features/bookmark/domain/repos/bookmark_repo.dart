import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/bookmark_action_result.dart';
import '../entities/bookmark_collection.dart';
import '../entities/user_bookmark.dart';

abstract class BookmarkRepo {
  Future<List<UserBookmark>?> getCachedBookmarks();

  Future<ApiResult<List<UserBookmark>>> getBookmarks();

  Future<List<BookmarkCollection>?> getCachedCollections();

  Future<ApiResult<List<BookmarkCollection>>> getCollections();

  Future<ApiResult<BookmarkActionResult>> addBookmark(UserBookmark bookmark);

  Future<ApiResult<BookmarkActionResult>> deleteBookmark(int bookmarkId);
}
