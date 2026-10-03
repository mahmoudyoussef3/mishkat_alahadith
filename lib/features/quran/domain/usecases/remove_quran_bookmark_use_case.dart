import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_bookmark.dart';
import '../repos/quran_reading_repo.dart';

class RemoveQuranBookmarkUseCase {
  final QuranReadingRepo _repo;

  RemoveQuranBookmarkUseCase(this._repo);

  Future<ApiResult<void>> call(QuranBookmark bookmark) async {
    final result = await _repo.updateBookmarks(
      (bookmarks) => bookmarks.where((b) => !b.sameTargetAs(bookmark)).toList(),
    );
    return switch (result) {
      ApiFailure(:final failure) => ApiResult.failure(failure),
      ApiSuccess() => const ApiResult.success(null),
    };
  }
}
