import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/cache_fallback.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/core/data/datasources/hadeethenc_datasource.dart';
import 'package:mishkat_almasabih/core/networking/network_info.dart';
import 'package:mishkat_almasabih/core/data/mappers/explained_hadith_mapper.dart';
import 'package:mishkat_almasabih/core/data/models/new_daily_hadith_model.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/hadith_entity.dart';
import '../../domain/repos/categories_repository.dart';
import '../datasources/categories_datasource.dart';
import '../mappers/hadith_mapper.dart';
import '../models/category_model.dart';
import '../models/hadith_by_category_model.dart';

class CategoriesRepositoryImpl implements CategoriesRepository {
  final CategoriesDatasource _datasource;
  final HadeethEncDataSource _hadeethEnc;
  final GenericCacheService _cacheService;
  final NetworkInfo _networkInfo;

  CategoriesRepositoryImpl(
    this._datasource,
    this._hadeethEnc,
    this._cacheService,
    this._networkInfo,
  );

  Future<List<CategoryModel>?> _getCachedCategories() =>
      _cacheService.getData<List<CategoryModel>>(
        key: CacheKeys.hadithCategories,
        fromJson: _categoriesFromJson,
      );

  static List<CategoryModel> _categoriesFromJson(Map<String, dynamic> json) {
    final items = json['categories'];
    if (items is! List) return <CategoryModel>[];
    return items
        .whereType<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
  }

  static List<CategoryEntity> _categoryEntities(List<CategoryModel> models) =>
      models.map((model) => model.toEntity()).toList();

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

  @override
  Future<ApiResult<List<CategoryEntity>>> getCategories() async {
    final cachedModels = await _getCachedCategories();
    if (cachedModels != null) {
      return ApiResult.success(_categoryEntities(cachedModels));
    }

    return _cacheService
        .fetchWithStaleFallback<List<CategoryModel>, List<CategoryEntity>>(
          key: CacheKeys.hadithCategories,
          fetch: _datasource.getCategories,
          toJson:
              (data) => {
                'categories':
                    data.map((category) => category.toJson()).toList(),
              },
          fromJson: _categoriesFromJson,
          toEntity: _categoryEntities,
        );
  }

  @override
  Future<ApiResult<HadithResponseEntity>> getAhadithByCategory(
    String categoryId, {
    int? page,
    int? perPage,
  }) async {
    final cached = await _getCachedAhadithByCategory(
      categoryId,
      page: page,
      perPage: perPage,
    );
    if (cached != null) return ApiResult.success(cached.toEntity());

    return _cacheService.fetchWithStaleFallback<
      HadithByCategoryResponseModel,
      HadithResponseEntity
    >(
      key: _ahadithByCategoryCacheKey(categoryId, page: page, perPage: perPage),
      fetch:
          () => _datasource.getAhadithByCategory(
            categoryId,
            page: page,
            perPage: perPage,
          ),
      toJson: (data) => data.toJson(),
      fromJson: HadithByCategoryResponseModel.fromJson,
      toEntity: (data) => data.toEntity(),
    );
  }

  @override
  Future<ExplainedHadith?> getCachedHadithDetails(String id) async {
    final cached = await _cacheService.getData<NewDailyHadithModel>(
      key: CacheKeys.hadithDetails(id),
      fromJson: NewDailyHadithModel.fromJson,
    );
    return cached?.toEntity();
  }

  @override
  Future<ApiResult<ExplainedHadith>> getHadithDetails(String id) =>
      _cacheService
          .fetchWithStaleFallback<NewDailyHadithModel, ExplainedHadith>(
            key: CacheKeys.hadithDetails(id),
            fetch: () async {
              await _networkInfo.ensureConnected();
              return _hadeethEnc.fetchHadith(id);
            },
            toJson: (d) => d.toJson(),
            fromJson: NewDailyHadithModel.fromJson,
            toEntity: (d) => d.toEntity(),
          );
}
