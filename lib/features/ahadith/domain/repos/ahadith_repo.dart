import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/chapter_ahadith_page.dart';
import 'package:mishkat_almasabih/core/domain/entities/chapter_hadith.dart';
import '../entities/local_book_hadith.dart';

abstract class AhadithRepo {
  Future<CachedChapterAhadith?> getCachedAhadith({
    required String bookSlug,
    required int chapterId,
  });

  Future<void> cacheAhadith({
    required String bookSlug,
    required int chapterId,
    required List<ChapterHadith> ahadith,
    required int lastLoadedPage,
    required int totalCount,
  });

  Future<ApiResult<ChapterAhadithPage>> getAhadithPage({
    required String bookSlug,
    required int chapterId,
    required int page,
    required int paginate,
  });

  Future<ApiResult<List<LocalBookHadith>>> getLocalAhadith({
    required String bookSlug,
    required int chapterId,
  });

  Future<ApiResult<List<LocalBookHadith>>> getArbainAhadith({
    required String bookSlug,
    required int chapterId,
  });
}
