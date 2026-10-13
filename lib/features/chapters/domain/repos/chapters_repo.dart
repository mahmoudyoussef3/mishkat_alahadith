import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/book_chapter.dart';
import '../entities/last_read_chapter.dart';

abstract class ChaptersRepo {
  Future<List<BookChapter>?> getCachedChapters(String bookSlug);

  Future<ApiResult<List<BookChapter>>> getChapters(String bookSlug);

  /// The chapter last opened in [bookSlug], or null if none yet.
  Future<ApiResult<LastReadChapter?>> getLastReadChapter(String bookSlug);

  Future<ApiResult<void>> saveLastReadChapter(
    String bookSlug,
    LastReadChapter chapter,
  );
}
