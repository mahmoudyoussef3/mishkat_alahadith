import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/features/navigation/data/models/local_hadith_navigation_model.dart'
    as local;
import 'package:mishkat_almasabih/features/navigation/data/models/navigation_hadith_model.dart'
    as remote;
import 'package:mishkat_almasabih/features/navigation/data/repos/navigation_repo_impl.dart';
import 'package:mishkat_almasabih/features/navigation/domain/entities/hadith_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiService extends Fake implements ApiService {
  @override
  Future<remote.NavigationHadithResponse> navigationHadith(
    String hadithNumber,
    String bookSlug,
    String chapterNumber,
  ) async => remote.NavigationHadithResponse(
    nextHadith: remote.Hadith(id: '12', title: 'التالي'),
    currentHadithNumber: '11',
    totalHadiths: 50,
  );

  @override
  Future<local.LocalNavigationHadithResponse> localNavigationHadith(
    String hadithNumber,
    String bookSlug,
  ) async => local.LocalNavigationHadithResponse(
    prevHadith: local.Hadith(id: 3, title: 'السابق'),
    currentHadithNumber: 4,
  );
}

void main() {
  final cache = GenericCacheService.instance;
  late NavigationRepoImpl repo;

  setUpAll(() => SharedPreferences.setMockInitialValues({}));
  setUp(() => repo = NavigationRepoImpl(_FakeApiService(), cache));
  tearDown(() => cache.clearCache(CacheKeys.navigation('bukhari', 2, '11')));

  test('getNavigation maps neighbours and caches under the chapter key', () async {
    final result = await repo.getNavigation(
      hadithNumber: '11',
      bookSlug: 'bukhari',
      chapterNumber: '2',
    );

    final nav = (result as ApiSuccess<HadithNavigation>).data;
    expect(nav.nextHadith?.id, '12');
    expect(nav.prevHadith, isNull);

    final cached = await repo.getCachedNavigation(
      hadithNumber: '11',
      bookSlug: 'bukhari',
      chapterNumber: '2',
    );
    expect(cached?.totalHadiths, 50);
  });

  test('getLocalNavigation converts integer ids to strings', () async {
    final result = await repo.getLocalNavigation(
      hadithNumber: '4',
      bookSlug: 'nawawi40',
    );

    final nav = (result as ApiSuccess<HadithNavigation>).data;
    expect(nav.prevHadith?.id, '3');
    expect(nav.currentHadithNumber, '4');
    expect(nav.nextHadith, isNull);
  });
}
