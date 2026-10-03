import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/bookmark_action_result.dart';
import '../entities/user_bookmark.dart';
import '../repos/bookmark_repo.dart';

class AddBookmarkUseCase {
  final BookmarkRepo _repo;

  AddBookmarkUseCase(this._repo);

  Future<ApiResult<BookmarkActionResult>> call(UserBookmark bookmark) =>
      _repo.addBookmark(bookmark);
}
