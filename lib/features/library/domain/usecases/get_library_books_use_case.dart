import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/category_books.dart';
import '../entities/library_book.dart';
import '../repos/library_repo.dart';

/// Books of several library categories as one shelf, in category order and
/// without duplicates (a book can be listed in more than one category).
class GetLibraryBooksUseCase {
  final LibraryRepo _repo;

  GetLibraryBooksUseCase(this._repo);

  /// The cached shelf, or null until every category has been cached.
  Future<List<LibraryBook>?> cached(List<String> categoryIds) async {
    final categories = await Future.wait(
      categoryIds.map(_repo.getCachedCategoryBooks),
    );
    if (categories.contains(null)) return null;
    return _merge(categories.nonNulls);
  }

  /// The shelf from the server. Categories that fail are skipped; the call
  /// fails only when every category does.
  Future<ApiResult<List<LibraryBook>>> call(List<String> categoryIds) async {
    final results = await Future.wait(categoryIds.map(_repo.getCategoryBooks));

    final loaded = [
      for (final result in results)
        if (result case ApiSuccess(:final data)) data,
    ];
    if (loaded.isEmpty) {
      for (final result in results) {
        if (result case ApiFailure(:final failure)) {
          return ApiResult.failure(failure);
        }
      }
    }
    return ApiResult.success(_merge(loaded));
  }

  static List<LibraryBook> _merge(Iterable<CategoryBooks> categories) {
    final seen = <String>{};
    return [
      for (final category in categories)
        for (final book in category.books)
          if (_identity(book) case final id when id.isEmpty || seen.add(id))
            book,
    ];
  }

  static String _identity(LibraryBook book) =>
      book.bookSlug ?? book.bookName ?? '';
}
