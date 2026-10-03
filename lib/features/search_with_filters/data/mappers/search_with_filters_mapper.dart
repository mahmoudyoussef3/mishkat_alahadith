import 'package:mishkat_almasabih/core/domain/entities/chapter_hadith.dart';

import '../models/search_with_filters_model.dart';

extension SearchWithFiltersModelMapper on SearchWithFiltersModel {
  List<ChapterHadith> toEntities() => [
    for (final hadith in search?.results?.data ?? const <HadithResult>[])
      hadith.toEntity(),
  ];
}

extension on HadithResult {
  ChapterHadith toEntity() => ChapterHadith(
    id: id,
    hadithNumber: hadithNumber,
    englishNarrator: englishNarrator,
    hadithEnglish: hadithEnglish,
    hadithUrdu: hadithUrdu,
    urduNarrator: urduNarrator,
    hadithArabic: hadithArabic,
    headingArabic: headingArabic,
    headingUrdu: headingUrdu,
    headingEnglish: headingEnglish,
    chapterId: chapterId,
    bookSlug: bookSlug,
    volume: volume,
    status: status,
    book:
        book == null
            ? null
            : HadithSourceBook(
              id: book!.id,
              bookName: book!.bookName,
              writerName: book!.writerName,
              aboutWriter: book!.aboutWriter,
              writerDeath: book!.writerDeath,
              bookSlug: book!.bookSlug,
            ),
    chapter:
        chapter == null
            ? null
            : HadithSourceChapter(
              id: chapter!.id,
              chapterNumber: chapter!.chapterNumber,
              chapterEnglish: chapter!.chapterEnglish,
              chapterUrdu: chapter!.chapterUrdu,
              chapterArabic: chapter!.chapterArabic,
              bookSlug: chapter!.bookSlug,
            ),
  );
}
