import '../../domain/entities/book_chapter.dart';
import '../models/chapters_model.dart';

extension ChaptersModelMapper on ChaptersModel {
  List<BookChapter> toEntities() => [
    for (final chapter in chapters ?? const <Chapter>[])
      BookChapter(
        chapterNumber: chapter.chapterNumber,
        chapterArabic: chapter.chapterArabic,
        chapterEnglish: chapter.chapterEnglish,
        chapterUrdu: chapter.chapterUrdu,
        hadithsCount: chapter.hadithsCount,
      ),
  ];
}
