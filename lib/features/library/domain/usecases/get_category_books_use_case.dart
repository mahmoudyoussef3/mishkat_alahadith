import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/category_books.dart';
import '../repos/library_repo.dart';

class GetCategoryBooksUseCase {
  final LibraryRepo _repo;

  GetCategoryBooksUseCase(this._repo);

  Future<ApiResult<CategoryBooks>> call(String categoryId) =>
      _repo.getCategoryBooks(categoryId);
}
