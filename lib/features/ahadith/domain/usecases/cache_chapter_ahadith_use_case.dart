import 'package:mishkat_almasabih/core/domain/entities/chapter_hadith.dart';
import '../repos/ahadith_repo.dart';

class CacheChapterAhadithUseCase {
  final AhadithRepo _repo;

  CacheChapterAhadithUseCase(this._repo);

  Future<void> call({
    required String bookSlug,
    required int chapterId,
    required List<ChapterHadith> ahadith,
    required int lastLoadedPage,
    required int totalCount,
  }) => _repo.cacheAhadith(
    bookSlug: bookSlug,
    chapterId: chapterId,
    ahadith: ahadith,
    lastLoadedPage: lastLoadedPage,
    totalCount: totalCount,
  );
}
