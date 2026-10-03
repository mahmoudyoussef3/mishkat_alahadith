class ChapterHadith {
  final int? id;
  final String? hadithNumber;
  final String? englishNarrator;
  final String? hadithEnglish;
  final String? hadithUrdu;
  final String? urduNarrator;
  final String? hadithArabic;
  final String? headingArabic;
  final String? headingUrdu;
  final String? headingEnglish;
  final String? chapterId;
  final String? bookSlug;
  final String? volume;
  final String? status;
  final HadithSourceBook? book;
  final HadithSourceChapter? chapter;

  const ChapterHadith({
    this.id,
    this.hadithNumber,
    this.englishNarrator,
    this.hadithEnglish,
    this.hadithUrdu,
    this.urduNarrator,
    this.hadithArabic,
    this.headingArabic,
    this.headingUrdu,
    this.headingEnglish,
    this.chapterId,
    this.bookSlug,
    this.volume,
    this.status,
    this.book,
    this.chapter,
  });
}

class HadithSourceBook {
  final int? id;
  final String? bookName;
  final String? writerName;
  final String? aboutWriter;
  final String? writerDeath;
  final String? bookSlug;

  const HadithSourceBook({
    this.id,
    this.bookName,
    this.writerName,
    this.aboutWriter,
    this.writerDeath,
    this.bookSlug,
  });
}

class HadithSourceChapter {
  final int? id;
  final String? chapterNumber;
  final String? chapterEnglish;
  final String? chapterUrdu;
  final String? chapterArabic;
  final String? bookSlug;

  const HadithSourceChapter({
    this.id,
    this.chapterNumber,
    this.chapterEnglish,
    this.chapterUrdu,
    this.chapterArabic,
    this.bookSlug,
  });
}

extension ChapterAhadithMerge on List<ChapterHadith> {
  List<ChapterHadith> appendUnique(List<ChapterHadith> newItems) {
    final existingIds = map((h) => h.id).toSet();
    return [...this, ...newItems.where((h) => !existingIds.contains(h.id))];
  }

  List<ChapterHadith> refreshedWith(List<ChapterHadith> fresh) {
    final freshIds = fresh.map((h) => h.id).toSet();
    return [...fresh, ...where((h) => !freshIds.contains(h.id))];
  }
}
