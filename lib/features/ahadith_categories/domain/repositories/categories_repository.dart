import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/hadith_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/category_entity.dart';
import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';

abstract class CategoriesRepository {
  Future<Either<ApiErrorModel, List<CategoryEntity>>> getCategories();
  Future<Either<ApiErrorModel, HadithResponseEntity>> getAhadithByCategory(
    String categoryId, {
      
    int? page,
    int? perPage,
  });
}
