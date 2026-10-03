import '../entities/bookmark_collection.dart';
import '../repos/bookmark_repo.dart';

class GetCachedBookmarkCollectionsUseCase {
  final BookmarkRepo _repo;

  GetCachedBookmarkCollectionsUseCase(this._repo);

  Future<List<BookmarkCollection>?> call() => _repo.getCachedCollections();
}
