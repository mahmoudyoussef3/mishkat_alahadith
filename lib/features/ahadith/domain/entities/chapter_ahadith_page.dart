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

  /// Saved too long ago to be merged into: once the chapter loads again it
  /// replaces these pages, and until then they stand in, offline included.
  final bool isStale;

  const CachedChapterAhadith({
    required this.ahadith,
    required this.lastLoadedPage,
    required this.totalCount,
    this.isStale = false,
  });
}
