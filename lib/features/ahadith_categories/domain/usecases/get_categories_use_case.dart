import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/category_entity.dart';
import '../repos/categories_repository.dart';

class GetCategoriesUseCase {
  final CategoriesRepository _repo;

  GetCategoriesUseCase(this._repo);

  Future<ApiResult<List<CategoryEntity>>> call() => _repo.getCategories();
}
