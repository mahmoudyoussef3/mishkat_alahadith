class LibraryBook {
  final int? id;
  final String? bookName;
  final String? bookNameEn;
  final String? bookNameUr;
  final String? writerName;
  final String? writerNameEn;
  final String? writerNameUr;
  final String? bookSlug;
  final int? hadithsCount;
  final int? chaptersCount;
  final String? status;
  final bool? isLocal;
  final String? category;
  final String? filePath;

  const LibraryBook({
    this.id,
    this.bookName,
    this.bookNameEn,
    this.bookNameUr,
    this.writerName,
    this.writerNameEn,
    this.writerNameUr,
    this.bookSlug,
    this.hadithsCount,
    this.chaptersCount,
    this.status,
    this.isLocal,
    this.category,
    this.filePath,
  });
}
