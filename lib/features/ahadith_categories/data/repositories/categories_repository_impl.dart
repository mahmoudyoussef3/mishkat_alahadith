import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/data/datasources/categories_datasource.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/hadith_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/category_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/repositories/categories_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/data/models/hadith_mapper.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesDatasource _datasource;

  CategoriesRepositoryImpl(this._datasource);

  @override
  Future<Either<ApiErrorModel, List<CategoryEntity>>> getCategories() async {
    try {
      final models = await _datasource.getCategories();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ApiErrorModel(message: e.toString()));
    }
  }

  @override
  Future<Either<ApiErrorModel, HadithResponseEntity>> getAhadithByCategory(
    String categoryId, {
    int? page,
    int? perPage,
  }) async {
    try {
      final response = await _datasource.getAhadithByCategory(
        categoryId,
        page: page,
        perPage: perPage,
      );
      return Right(response.toEntity());
    } catch (e) {
      return Left(ApiErrorModel(message: e.toString()));
    }
  }
}
