import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/bookmark_action_result.dart';
import '../repos/bookmark_repo.dart';

class DeleteBookmarkUseCase {
  final BookmarkRepo _repo;

  DeleteBookmarkUseCase(this._repo);

  Future<ApiResult<BookmarkActionResult>> call(int bookmarkId) =>
      _repo.deleteBookmark(bookmarkId);
}
