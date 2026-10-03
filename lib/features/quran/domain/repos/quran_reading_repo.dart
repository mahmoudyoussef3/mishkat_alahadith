import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/mushaf_reader_settings.dart';
import '../entities/quran_bookmark.dart';
import '../entities/quran_last_read.dart';

/// What the reader keeps on the device: where they stopped, what they
/// bookmarked, and how they like the page.
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
}
