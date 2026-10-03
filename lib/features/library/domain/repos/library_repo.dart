import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/category_books.dart';
import '../entities/library_statistics.dart';

abstract class LibraryRepo {
  Future<CategoryBooks?> getCachedCategoryBooks(String categoryId);

  Future<ApiResult<CategoryBooks>> getCategoryBooks(String categoryId);

  Future<LibraryStatistics?> getCachedStatistics();

  Future<ApiResult<LibraryStatistics>> getStatistics();
}
