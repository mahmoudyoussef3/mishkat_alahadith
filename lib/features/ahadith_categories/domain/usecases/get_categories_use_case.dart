import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities_temp/category_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/repositories/categories_repository.dart';
import 'package:dartz/dartz.dart';

class GetCategoriesUseCase {
  final CategoriesRepository _repository;

  GetCategoriesUseCase(this._repository);

  Future<Either<ApiErrorModel, List<CategoryEntity>>> call() async {
    return await _repository.getCategories();
  }
}
