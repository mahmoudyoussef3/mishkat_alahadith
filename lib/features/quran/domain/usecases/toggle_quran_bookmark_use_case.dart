import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/quran_bookmark.dart';
import '../repos/quran_reading_repo.dart';

/// Saves the place if it is not bookmarked yet, removes it if it is.
///
/// Succeeds with `true` when the place is now bookmarked, `false` when the
/// bookmark was removed.
class ToggleQuranBookmarkUseCase {
  final QuranReadingRepo _repo;
  final DateTime Function() _now;

  ToggleQuranBookmarkUseCase(this._repo, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  Future<ApiResult<bool>> call({
    required int page,
    required int surahNumber,
    required String surahName,
    int? ayahId,
    int? ayahNumber,
  }) async {
    final candidate = QuranBookmark(
      page: page,
      surahNumber: surahNumber,
      surahName: surahName,
      ayahId: ayahId,
      ayahNumber: ayahNumber,
      createdAt: _now(),
    );

    var added = false;
    final result = await _repo.updateBookmarks((bookmarks) {
      final exists = bookmarks.any((b) => b.sameTargetAs(candidate));
      added = !exists;
      return exists
          ? bookmarks.where((b) => !b.sameTargetAs(candidate)).toList()
          : [candidate, ...bookmarks];
    });
    return switch (result) {
      ApiFailure(:final failure) => ApiResult.failure(failure),
      ApiSuccess() => ApiResult.success(added),
    };
  }
}
