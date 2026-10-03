import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_bookmark.dart';
import '../repos/quran_reading_repo.dart';

/// Newest first.
class GetQuranBookmarksUseCase {
  final QuranReadingRepo _repo;

  GetQuranBookmarksUseCase(this._repo);

  Future<ApiResult<List<QuranBookmark>>> call() async {
    final result = await _repo.getBookmarks();
    return switch (result) {
      ApiFailure(:final failure) => ApiResult.failure(failure),
      ApiSuccess(data: final bookmarks) => ApiResult.success(
        [...bookmarks]..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      ),
    };
  }
}
