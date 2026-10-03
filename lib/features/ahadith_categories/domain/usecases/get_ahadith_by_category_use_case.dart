import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/hadith_entity.dart';
import '../repos/categories_repository.dart';

class GetAhadithByCategoryUseCase {
  final CategoriesRepository _repo;

  GetAhadithByCategoryUseCase(this._repo);

  Future<ApiResult<HadithResponseEntity>> call(
    String categoryId, {
    int? page,
    int? perPage,
  }) => _repo.getAhadithByCategory(categoryId, page: page, perPage: perPage);
}
