import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities_temp/hadith_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities_temp/category_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/repositories/categories_repository.dart';
import 'package:dartz/dartz.dart';

class GetAhadithByCategoryUseCase {
  final CategoriesRepository _repository;

  GetAhadithByCategoryUseCase(this._repository);

  Future<Either<ApiErrorModel, HadithResponseEntity>> call(
    String categoryId, {
    int? page,
    int? perPage,
  }) async {
    return await _repository.getAhadithByCategory(
      categoryId,
      page: page,
      perPage: perPage,
    );
  }
}
