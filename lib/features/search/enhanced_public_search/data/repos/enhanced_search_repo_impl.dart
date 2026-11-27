import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/cache_fallback.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/core/networking/network_info.dart';

import '../../domain/repos/enhanced_search_repo.dart';
import '../mappers/enhanced_search_mapper.dart';
import '../models/enhanced_search_response_model.dart';

class EnhancedSearchRepoImpl implements EnhancedSearchRepo {
  final ApiService _apiService;
  final GenericCacheService _cacheService;
  final NetworkInfo _networkInfo;

  EnhancedSearchRepoImpl(
    this._apiService,
    this._cacheService,
    this._networkInfo,
  );

  @override
  Future<List<ExplainedHadith>?> getCachedResults(String searchTerm) async {
    final cached = await _cacheService.getData<EnhancedSearch>(
      key: CacheKeys.enhancedSearch(searchTerm),
      fromJson: EnhancedSearch.fromJson,
    );
    return cached?.toEntities();
  }

  @override
  Future<ApiResult<List<ExplainedHadith>>> search(String searchTerm) =>
      _cacheService
          .fetchWithStaleFallback<EnhancedSearch, List<ExplainedHadith>>(
            key: CacheKeys.enhancedSearch(searchTerm),
            fetch: () async {
              await _networkInfo.ensureConnected();
              return _apiService.getEnhancedSearch({"searchTerm": searchTerm});
            },
            toJson: (d) => d.toJson(),
            fromJson: EnhancedSearch.fromJson,
            toEntity: (d) => d.toEntities(),
            cacheExpirationHours: 6,
          );
}
