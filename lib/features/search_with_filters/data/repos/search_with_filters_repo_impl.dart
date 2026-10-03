import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/core/networking/network_info.dart';
import 'package:mishkat_almasabih/core/domain/entities/chapter_hadith.dart';

import '../../domain/entities/hadith_search_filters.dart';
import '../../domain/repos/search_with_filters_repo.dart';
import '../mappers/search_with_filters_mapper.dart';
import '../models/search_with_filters_model.dart';

class SearchWithFiltersRepoImpl implements SearchWithFiltersRepo {
  final ApiService _apiService;
  final GenericCacheService _cacheService;
  final NetworkInfo _networkInfo;

  SearchWithFiltersRepoImpl(
    this._apiService,
    this._cacheService,
    this._networkInfo,
  );

  String _cacheKey(HadithSearchFilters f) => CacheKeys.searchWithFilters(
    f.query,
    f.bookSlug,
    f.narrator,
    f.grade,
    f.chapter,
    f.category,
  );

  @override
  Future<List<ChapterHadith>?> getCachedResults(
    HadithSearchFilters filters,
  ) async {
    final cached = await _cacheService.getData<SearchWithFiltersModel>(
      key: _cacheKey(filters),
      fromJson: SearchWithFiltersModel.fromJson,
    );
    return cached?.toEntities();
  }

  @override
  Future<ApiResult<List<ChapterHadith>>> search(
    HadithSearchFilters filters,
  ) async {
    try {
      await _networkInfo.ensureConnected();
      final response = await _apiService.searchWithFilters(
        filters.query,
        filters.bookSlug,
        filters.narrator,
        filters.grade,
        filters.chapter,
        filters.category,
      );
      await _cacheService.saveData<SearchWithFiltersModel>(
        key: _cacheKey(filters),
        data: response,
        toJson: (d) => d.toJson(),
        cacheExpirationHours: 6,
      );
      return ApiResult.success(response.toEntities());
    } catch (error) {
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }
}
