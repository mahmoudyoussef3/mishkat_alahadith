import '../entities/user_bookmark.dart';
import '../repos/bookmark_repo.dart';

class GetCachedBookmarksUseCase {
  final BookmarkRepo _repo;

  GetCachedBookmarksUseCase(this._repo);

  Future<List<UserBookmark>?> call() => _repo.getCachedBookmarks();
}
