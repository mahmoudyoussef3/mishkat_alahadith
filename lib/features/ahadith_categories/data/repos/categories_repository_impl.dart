import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
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
  Future<ApiResult<List<CategoryEntity>>> getCategories() async {
    try {
      final cachedModels = await _getCachedCategories();
      if (cachedModels != null) {
        final entities = cachedModels.map((model) => model.toEntity()).toList();
        return ApiResult.success(entities);
      }

      final models = await _datasource.getCategories();
      await _cacheCategories(models);
      final entities = models.map((model) => model.toEntity()).toList();
      return ApiResult.success(entities);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }

  @override
  Future<ApiResult<HadithResponseEntity>> getAhadithByCategory(
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
        return ApiResult.success(cached.toEntity());
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
      return ApiResult.success(response.toEntity());
    } catch (error) {
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
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
  Future<ApiResult<ExplainedHadith>> getHadithDetails(String id) async {
    try {
      await _networkInfo.ensureConnected();
      final model = await _hadeethEnc.fetchHadith(id);
      await _cacheService.saveData<NewDailyHadithModel>(
        key: CacheKeys.hadithDetails(id),
        data: model,
        toJson: (d) => d.toJson(),
        cacheExpirationHours: 24,
      );
      return ApiResult.success(model.toEntity());
    } catch (error) {
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }
}
