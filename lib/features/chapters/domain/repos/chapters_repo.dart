import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/book_chapter.dart';

abstract class ChaptersRepo {
  Future<List<BookChapter>?> getCachedChapters(String bookSlug);

  Future<ApiResult<List<BookChapter>>> getChapters(String bookSlug);
}
