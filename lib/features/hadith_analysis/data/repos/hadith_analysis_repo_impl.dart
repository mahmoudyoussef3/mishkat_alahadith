import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/cache_fallback.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';

import '../../domain/entities/hadith_analysis_result.dart';
import '../../domain/repos/hadith_analysis_repo.dart';
import '../mappers/hadith_analysis_mapper.dart';
import '../models/hadith_analysis_request.dart';
import '../models/hadith_analysis_response.dart';

class HadithAnalysisRepoImpl implements HadithAnalysisRepo {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;
  final GenericCacheService _cacheService;

  HadithAnalysisRepoImpl(
    this._apiService,
    this._tokenStorage,
    this._cacheService,
  );

  /// Always asks the server, so each analysis is fresh and counted as
  /// before; the last analysis of the same hadith is only shown when the
  /// server cannot be reached.
  @override
  Future<ApiResult<HadithAnalysisResult>> analyzeHadith({
    required String hadith,
    required String attribution,
    required String grade,
    required String reference,
  }) => _cacheService
      .fetchWithStaleFallback<HadithAnalysisResponse, HadithAnalysisResult>(
        key: CacheKeys.hadithAnalysis(hadith, attribution, grade, reference),
        fetch: () async {
          final token = await _tokenStorage.requireToken();
          return _apiService.hadithAnalysis(
            HadithAnalysisRequest(
              hadeeth: hadith,
              attribution: attribution,
              grade: grade,
              reference: reference,
            ),
            token,
          );
        },
        toJson: (d) => d.toJson(),
        fromJson: HadithAnalysisResponse.fromJson,
        toEntity: (d) => d.toEntity(),
      );
}
