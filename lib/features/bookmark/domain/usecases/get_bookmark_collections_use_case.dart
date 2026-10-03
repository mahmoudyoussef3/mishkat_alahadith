import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/bookmark_collection.dart';
import '../repos/bookmark_repo.dart';

class GetBookmarkCollectionsUseCase {
  final BookmarkRepo _repo;

  GetBookmarkCollectionsUseCase(this._repo);

  Future<ApiResult<List<BookmarkCollection>>> call() => _repo.getCollections();
}
