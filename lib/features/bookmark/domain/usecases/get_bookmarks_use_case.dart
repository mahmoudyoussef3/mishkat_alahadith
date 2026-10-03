import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/user_bookmark.dart';
import '../repos/bookmark_repo.dart';

class GetBookmarksUseCase {
  final BookmarkRepo _repo;

  GetBookmarksUseCase(this._repo);

  Future<ApiResult<List<UserBookmark>>> call() => _repo.getBookmarks();
}
