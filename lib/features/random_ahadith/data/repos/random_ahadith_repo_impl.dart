import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/core/networking/network_info.dart';

import '../../domain/repos/random_ahadith_repo.dart';
import '../datasources/custom_api_service.dart';
import '../mappers/random_ahadith_mapper.dart';
import '../models/random_ahadith_model.dart';

class RandomAhadithRepoImpl implements RandomAhadithRepo {
  final CustomApiService _customApiService;
  final NetworkInfo _networkInfo;
  final GenericCacheService _cacheService;

  RandomAhadithRepoImpl(
    this._customApiService,
    this._networkInfo,
    this._cacheService,
  );

  /// A new selection, kept for offline use. A failure is reported as is:
  /// asking for a new selection and silently getting the old one back
  /// would hide that the refresh failed.
  @override
  Future<ApiResult<List<ExplainedHadith>>> getRandomAhadith() async {
    try {
      await _networkInfo.ensureConnected();
      final response = await _customApiService.getRandomAhadith();
      final hadiths = response.toEntities();
      await _cacheService.saveData<RandomAhadithResponse>(
        key: CacheKeys.randomAhadith,
        data: response,
        toJson: (d) => d.toJson(),
      );
      return ApiResult.success(hadiths);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }

  @override
  Future<List<ExplainedHadith>?> getCachedRandomAhadith() async {
    final cached = await _cacheService.getData<RandomAhadithResponse>(
      key: CacheKeys.randomAhadith,
      fromJson: RandomAhadithResponse.fromJson,
      allowStale: true,
    );
    return cached?.toEntities();
  }
}
