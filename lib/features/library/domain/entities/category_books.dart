import 'library_book.dart';

class CategoryBooks {
  final BookCategory? category;
  final List<LibraryBook> books;

  const CategoryBooks({this.category, this.books = const []});
}

class BookCategory {
  final String? id;
  final String? name;
  final String? nameEn;
  final String? nameUr;
  final String? description;
  final String? descriptionEn;
  final String? descriptionUr;
  final List<String> bookSlugs;

  const BookCategory({
    this.id,
    this.name,
    this.nameEn,
    this.nameUr,
    this.description,
    this.descriptionEn,
    this.descriptionUr,
    this.bookSlugs = const [],
  });
}
