import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/cache_fallback.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';

import '../../domain/entities/hadith_navigation.dart';
import '../../domain/repos/navigation_repo.dart';
import '../mappers/navigation_mapper.dart';
import '../models/local_hadith_navigation_model.dart';
import '../models/navigation_hadith_model.dart';

class NavigationRepoImpl implements NavigationRepo {
  final ApiService _apiService;
  final GenericCacheService _cacheService;

  NavigationRepoImpl(this._apiService, this._cacheService);

  String _cacheKey(
    String bookSlug,
    String chapterNumber,
    String hadithNumber,
  ) => CacheKeys.navigation(
    bookSlug,
    int.tryParse(chapterNumber) ?? 0,
    hadithNumber,
  );

  @override
  Future<HadithNavigation?> getCachedNavigation({
    required String hadithNumber,
    required String bookSlug,
    required String chapterNumber,
  }) async {
    final cached = await _cacheService.getData<NavigationHadithResponse>(
      key: _cacheKey(bookSlug, chapterNumber, hadithNumber),
      fromJson: NavigationHadithResponse.fromJson,
    );
    return cached?.toEntity();
  }

  @override
  Future<ApiResult<HadithNavigation>> getNavigation({
    required String hadithNumber,
    required String bookSlug,
    required String chapterNumber,
  }) => _cacheService
      .fetchWithStaleFallback<NavigationHadithResponse, HadithNavigation>(
        key: _cacheKey(bookSlug, chapterNumber, hadithNumber),
        fetch:
            () => _apiService.navigationHadith(
              hadithNumber,
              bookSlug,
              chapterNumber,
            ),
        toJson: (d) => d.toJson(),
        fromJson: NavigationHadithResponse.fromJson,
        toEntity: (d) => d.toEntity(),
      );

  @override
  Future<ApiResult<HadithNavigation>> getLocalNavigation({
    required String hadithNumber,
    required String bookSlug,
  }) => _cacheService
      .fetchWithStaleFallback<LocalNavigationHadithResponse, HadithNavigation>(
        key: CacheKeys.localNavigation(bookSlug, hadithNumber),
        fetch: () => _apiService.localNavigationHadith(hadithNumber, bookSlug),
        toJson: (d) => d.toJson(),
        fromJson: LocalNavigationHadithResponse.fromJson,
        toEntity: (d) => d.toEntity(),
      );
}
