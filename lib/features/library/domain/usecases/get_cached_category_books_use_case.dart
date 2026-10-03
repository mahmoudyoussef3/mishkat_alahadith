import '../entities/category_books.dart';
import '../repos/library_repo.dart';

class GetCachedCategoryBooksUseCase {
  final LibraryRepo _repo;

  GetCachedCategoryBooksUseCase(this._repo);

  Future<CategoryBooks?> call(String categoryId) =>
      _repo.getCachedCategoryBooks(categoryId);
}
