import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/data/datasources/categories_datasource.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/data/models/category_model.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/data/models/hadith_by_category_model.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/hadith_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/category_entity.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/repositories/categories_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/data/models/hadith_mapper.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesDatasource _datasource;
  final _cacheService = GenericCacheService.instance;

  CategoriesRepositoryImpl(this._datasource);

  Future<List<CategoryModel>?> _getCachedCategories() async {
    return await _cacheService.getData<List<CategoryModel>>(
      key: CacheKeys.hadithCategories,
      fromJson: (json) {
        final items = json['categories'];
        if (items is! List) {
          return <CategoryModel>[];
        }
        return items
            .whereType<Map<String, dynamic>>()
            .map(CategoryModel.fromJson)
            .toList();
      },
    );
  }

  Future<void> _cacheCategories(List<CategoryModel> categories) async {
    await _cacheService.saveData<List<CategoryModel>>(
      key: CacheKeys.hadithCategories,
      data: categories,
      toJson:
          (data) => {
            'categories': data.map((category) => category.toJson()).toList(),
          },
      cacheExpirationHours: 24,
    );
  }

  String _ahadithByCategoryCacheKey(
    String categoryId, {
    int? page,
    int? perPage,
  }) {
    final resolvedPage = page ?? 1;
    final resolvedPerPage = perPage ?? 0;
    return CacheKeys.ahadithByCategory(
      categoryId,
      resolvedPage,
      resolvedPerPage,
    );
  }

  Future<HadithByCategoryResponseModel?> _getCachedAhadithByCategory(
    String categoryId, {
    int? page,
    int? perPage,
  }) async {
    final cacheKey = _ahadithByCategoryCacheKey(
      categoryId,
      page: page,
      perPage: perPage,
    );
    return await _cacheService.getData<HadithByCategoryResponseModel>(
      key: cacheKey,
      fromJson: HadithByCategoryResponseModel.fromJson,
    );
  }

  Future<void> _cacheAhadithByCategory(
    String categoryId,
    HadithByCategoryResponseModel response, {
    int? page,
    int? perPage,
  }) async {
    final cacheKey = _ahadithByCategoryCacheKey(
      categoryId,
      page: page,
      perPage: perPage,
    );
    await _cacheService.saveData<HadithByCategoryResponseModel>(
      key: cacheKey,
      data: response,
      toJson: (data) => data.toJson(),
      cacheExpirationHours: 24,
    );
  }

  @override
  Future<Either<ApiErrorModel, List<CategoryEntity>>> getCategories() async {
    try {
      final cachedModels = await _getCachedCategories();
      if (cachedModels != null) {
        final entities = cachedModels.map((model) => model.toEntity()).toList();
        return Right(entities);
      }

      final models = await _datasource.getCategories();
      await _cacheCategories(models);
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
      final cached = await _getCachedAhadithByCategory(
        categoryId,
        page: page,
        perPage: perPage,
      );
      if (cached != null) {
        return Right(cached.toEntity());
      }

      final response = await _datasource.getAhadithByCategory(
        categoryId,
        page: page,
        perPage: perPage,
      );
      await _cacheAhadithByCategory(
        categoryId,
        response,
        page: page,
        perPage: perPage,
      );
      return Right(response.toEntity());
    } catch (e) {
      return Left(ApiErrorModel(message: e.toString()));
    }
  }
}
