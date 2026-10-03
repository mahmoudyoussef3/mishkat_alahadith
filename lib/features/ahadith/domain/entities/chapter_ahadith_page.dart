import 'package:mishkat_almasabih/core/domain/entities/chapter_hadith.dart';

class ChapterAhadithPage {
  final List<ChapterHadith> ahadith;
  final int totalPages;
  final int total;

  const ChapterAhadithPage({
    required this.ahadith,
    required this.totalPages,
    required this.total,
  });
}

class CachedChapterAhadith {
  final List<ChapterHadith> ahadith;
  final int lastLoadedPage;
  final int totalCount;

  const CachedChapterAhadith({
    required this.ahadith,
    required this.lastLoadedPage,
    required this.totalCount,
  });
}
