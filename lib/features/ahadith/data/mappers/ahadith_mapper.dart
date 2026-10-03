import 'package:mishkat_almasabih/core/domain/entities/chapter_hadith.dart';
import '../../domain/entities/local_book_hadith.dart';
import '../models/ahadiths_model.dart';
import '../models/local_books_model.dart';

extension HadithMapper on Hadith {
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

extension ChapterHadithMapper on ChapterHadith {
  Hadith toModel() => Hadith(
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
            : HadithBook(
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
            : HadithChapter(
              id: chapter!.id,
              chapterNumber: chapter!.chapterNumber,
              chapterEnglish: chapter!.chapterEnglish,
              chapterUrdu: chapter!.chapterUrdu,
              chapterArabic: chapter!.chapterArabic,
              bookSlug: chapter!.bookSlug,
            ),
  );
}

extension LocalHadithResponseMapper on LocalHadithResponse {
  List<LocalBookHadith> toEntities() => [
    for (final hadith in hadiths?.data ?? const <LocalHadith>[])
      LocalBookHadith(
        id: hadith.id,
        idInBook: hadith.idInBook,
        chapterId: hadith.chapterId,
        bookId: hadith.bookId,
        arabic: hadith.arabic,
        englishNarrator: hadith.english?.narrator,
        englishText: hadith.english?.text,
      ),
  ];
}
