import '../../domain/entities/category_books.dart';
import '../../domain/entities/library_book.dart';
import '../../domain/entities/library_statistics.dart';
import '../models/book_data_model.dart';
import '../models/library_statistics_model.dart';

extension BookMapper on Book {
  LibraryBook toEntity() => LibraryBook(
    id: id,
    bookName: bookName,
    bookNameEn: bookNameEn,
    bookNameUr: bookNameUr,
    writerName: writerName,
    writerNameEn: writerNameEn,
    writerNameUr: writerNameUr,
    bookSlug: bookSlug,
    hadithsCount: hadiths_count,
    chaptersCount: chapters_count,
    status: status,
    isLocal: isLocal,
    category: category,
    filePath: filePath,
  );
}

extension CategoryResponseMapper on CategoryResponse {
  CategoryBooks toEntity() => CategoryBooks(
    category:
        category == null
            ? null
            : BookCategory(
              id: category!.id,
              name: category!.name,
              nameEn: category!.nameEn,
              nameUr: category!.nameUr,
              description: category!.description,
              descriptionEn: category!.descriptionEn,
              descriptionUr: category!.descriptionUr,
              bookSlugs: category!.books ?? const [],
            ),
    books: [for (final book in books ?? const <Book>[]) book.toEntity()],
  );
}

extension StatisticsResponseMapper on StatisticsResponse {
  LibraryStatistics toEntity() => LibraryStatistics(
    totalBooks: statistics.totalBooks,
    totalHadiths: statistics.totalHadiths,
    totalChapters: statistics.totalChapters,
    booksByCategory: statistics.booksByCategory.map(
      (key, value) => MapEntry(
        key,
        CategoryStatistics(
          name: value.name,
          nameEn: value.nameEn,
          nameUr: value.nameUr,
          count: value.count,
          hadiths: value.hadiths,
        ),
      ),
    ),
    topBooks: [
      for (final book in statistics.topBooks)
        TopBookStatistics(
          name: book.name,
          hadiths: book.hadiths,
          chapters: book.chapters,
        ),
    ],
    lastUpdated: statistics.lastUpdated,
  );
}
