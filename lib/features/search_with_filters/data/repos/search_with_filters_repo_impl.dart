import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/cache_fallback.dart';
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
  Future<ApiResult<List<ChapterHadith>>> search(HadithSearchFilters filters) =>
      _cacheService
          .fetchWithStaleFallback<SearchWithFiltersModel, List<ChapterHadith>>(
            key: _cacheKey(filters),
            fetch: () async {
              await _networkInfo.ensureConnected();
              return _apiService.searchWithFilters(
                filters.query,
                filters.bookSlug,
                filters.narrator,
                filters.grade,
                filters.chapter,
                filters.category,
              );
            },
            toJson: (d) => d.toJson(),
            fromJson: SearchWithFiltersModel.fromJson,
            toEntity: (d) => d.toEntities(),
            cacheExpirationHours: 6,
          );
}
