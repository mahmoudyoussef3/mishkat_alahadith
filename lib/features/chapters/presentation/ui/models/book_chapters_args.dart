/// What the book chapters screen needs to know about the book it opens.
class BookChaptersArgs {
  final String bookSlug;
  final String bookName;
  final String? writerName;
  final int? chaptersCount;
  final int? hadithsCount;

  /// Asset path of the cover, when the book has one.
  final String? coverImage;

  const BookChaptersArgs({
    required this.bookSlug,
    required this.bookName,
    this.writerName,
    this.chaptersCount,
    this.hadithsCount,
    this.coverImage,
  });
}
