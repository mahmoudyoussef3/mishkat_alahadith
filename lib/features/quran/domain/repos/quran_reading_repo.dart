import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/mushaf_reader_settings.dart';
import '../entities/quran_bookmark.dart';
import '../entities/quran_last_read.dart';
import '../entities/recitation.dart';
import '../entities/recitation_settings.dart';

/// What the reader keeps on the device: where they stopped, what they
/// bookmarked, how they like the page, and how they listen and study.
abstract class QuranReadingRepo {
  Future<ApiResult<QuranLastRead?>> getLastRead();

  Future<ApiResult<void>> saveLastRead(QuranLastRead lastRead);

  Future<ApiResult<List<QuranBookmark>>> getBookmarks();

  /// Replaces the bookmarks with `change(current)` as one step.
  ///
  /// Concurrent updates run one after another, each seeing the result of the
  /// one before, so two quick taps can never both read the same old list.
  Future<ApiResult<List<QuranBookmark>>> updateBookmarks(
    List<QuranBookmark> Function(List<QuranBookmark> current) change,
  );

  Future<ApiResult<MushafReaderSettings>> getSettings();

  Future<ApiResult<void>> saveSettings(MushafReaderSettings settings);

  Future<ApiResult<RecitationSettings>> getRecitationSettings();

  Future<ApiResult<void>> saveRecitationSettings(RecitationSettings settings);

  /// Where the last recitation was left off, or null when it was ended.
  Future<ApiResult<RecitationResumePoint?>> getRecitationResumePoint();

  /// Keeps [point] for after the app is closed; null forgets the one kept.
  Future<ApiResult<void>> saveRecitationResumePoint(
    RecitationResumePoint? point,
  );

  Future<ApiResult<CommentarySettings>> getCommentarySettings();

  Future<ApiResult<void>> saveCommentarySettings(CommentarySettings settings);
}
