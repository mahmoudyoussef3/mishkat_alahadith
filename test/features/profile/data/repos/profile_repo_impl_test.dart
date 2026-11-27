import 'package:dio/dio.dart';
import 'dart:io';

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
  Object? error;

  @override
  Future<UserResponseModel> getUserProfile(String token) async =>
      error != null ? throw error! : UserResponseModel(
        username: 'mahmoud',
        email: 'm@example.com',
        password: 'password-hash',
        googleAccessToken: 'google-access',
        googleRefreshToken: 'google-refresh',
      );

  @override
  Future<UserResponseModel> updateUserProfile(
    String token,
    String username,
    File? avatar,
  ) async => UserResponseModel(username: username, password: 'password-hash');

  @override
  Future<StatsModel> getUserStats(String token) async =>
      error != null ? throw error! : StatsModel(
    bookmarksCount: 4,
    topCollections: [TopCollection(name: 'المفضلة', count: 2)],
  );
}


DioException _offline() => DioException(
  requestOptions: RequestOptions(path: '/offline'),
  type: DioExceptionType.connectionError,
);

void main() {
  final cache = GenericCacheService.instance;
  late _FakeApiService api;
  late ProfileRepoImpl repo;

  setUpAll(() => SharedPreferences.setMockInitialValues({'token': 't1'}));

  setUp(() {
    api = _FakeApiService();
    repo = ProfileRepoImpl(api, TokenStorage(), cache);
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

  test('offline, getProfile returns the profile fetched before', () async {
    await repo.getProfile();
    api.error = _offline();

    final result = await repo.getProfile();

    expect((result as ApiSuccess).data.username, 'mahmoud');
  });

  test('offline, getStats returns the stats fetched before', () async {
    await repo.getStats();
    api.error = _offline();

    final result = await repo.getStats();

    expect((result as ApiSuccess<UserStats>).data.bookmarksCount, 4);
  });

  test('offline after an edit, getProfile shows the edited profile', () async {
    await repo.getProfile();
    await repo.updateProfile(username: 'mahmoud2');
    api.error = _offline();

    final result = await repo.getProfile();

    expect((result as ApiSuccess).data.username, 'mahmoud2');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('${CacheKeys.userProfile}_data'), isNot(contains('password-hash')));
  });
}
