class UserBookmark {
  final int? id;
  final int? userId;
  final String? type;
  final String? bookSlug;
  final String? bookName;
  final String? bookNameEn;
  final String? bookNameUr;
  final int? chapterNumber;
  final String? chapterName;
  final String? chapterNameEn;
  final String? chapterNameUr;
  final String? hadithId;
  final String? hadithNumber;
  final String? hadithText;
  final String? hadithTextEn;
  final String? hadithTextUr;
  final String? collection;
  final String? notes;
  final int? isLocal;
  final String? createdAt;
  final String? updatedAt;

  const UserBookmark({
    this.id,
    this.userId,
    this.type,
    this.bookSlug,
    this.bookName,
    this.bookNameEn,
    this.bookNameUr,
    this.chapterNumber,
    this.chapterName,
    this.chapterNameEn,
    this.chapterNameUr,
    this.hadithId,
    this.hadithNumber,
    this.hadithText,
    this.hadithTextEn,
    this.hadithTextUr,
    this.collection,
    this.notes,
    this.isLocal,
    this.createdAt,
    this.updatedAt,
  });
}
