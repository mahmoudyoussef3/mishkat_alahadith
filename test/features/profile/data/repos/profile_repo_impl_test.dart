import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';
import 'package:mishkat_almasabih/features/profile/data/models/stats_model.dart';
import 'package:mishkat_almasabih/features/profile/data/models/user_response_model.dart';
import 'package:mishkat_almasabih/features/profile/data/repos/profile_repo_impl.dart';
import 'package:mishkat_almasabih/features/profile/domain/entities/user_stats.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiService extends Fake implements ApiService {
  @override
  Future<UserResponseModel> getUserProfile(String token) async =>
      UserResponseModel(
        username: 'mahmoud',
        email: 'm@example.com',
        password: 'password-hash',
        googleAccessToken: 'google-access',
        googleRefreshToken: 'google-refresh',
      );

  @override
  Future<StatsModel> getUserStats(String token) async => StatsModel(
    bookmarksCount: 4,
    topCollections: [TopCollection(name: 'المفضلة', count: 2)],
  );
}

void main() {
  final cache = GenericCacheService.instance;
  late ProfileRepoImpl repo;

  setUpAll(() => SharedPreferences.setMockInitialValues({'token': 't1'}));

  setUp(() {
    repo = ProfileRepoImpl(_FakeApiService(), TokenStorage(), cache);
  });

  tearDown(() async {
    await cache.clearCache(CacheKeys.userProfile);
    await cache.clearCache(CacheKeys.userStats);
  });

  test('getProfile caches the profile without credentials', () async {
    await repo.getProfile();

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('${CacheKeys.userProfile}_data')!;
    expect(stored, contains('mahmoud'));
    expect(stored, isNot(contains('password-hash')));
    expect(stored, isNot(contains('google-access')));
    expect(stored, isNot(contains('google-refresh')));
  });

  test('getCachedProfile returns the last fetched profile as an entity', () async {
    expect(await repo.getCachedProfile(), isNull);

    await repo.getProfile();
    final cached = await repo.getCachedProfile();

    expect(cached?.username, 'mahmoud');
    expect(cached?.email, 'm@example.com');
  });

  test('getStats maps top collections into the entity', () async {
    final result = await repo.getStats();

    final stats = (result as ApiSuccess<UserStats>).data;
    expect(stats.bookmarksCount, 4);
    expect(stats.topCollections.single.name, 'المفضلة');
  });

  test('updateProfile fails with UnauthorizedFailure when signed out', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    addTearDown(() => prefs.setString('token', 't1'));

    final result = await repo.updateProfile(username: 'new');

    expect((result as ApiFailure).failure, isA<UnauthorizedFailure>());
  });
}
