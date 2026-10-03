import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';
import 'package:mishkat_almasabih/features/authentication/session/data/repos/session_repo_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _UnclearableCache extends Fake implements GenericCacheService {
  @override
  Future<bool> clearCache(String key) async => false;
}

class _StuckTokenStorage extends TokenStorage {
  @override
  Future<bool> clearToken() async => false;
}

void main() {
  final cache = GenericCacheService.instance;
  final repo = SessionRepoImpl(TokenStorage(), cache);

  Future<void> seedCache(String key) => cache.saveData<Map<String, dynamic>>(
    key: key,
    data: {'owner': 'previous user'},
    toJson: (d) => d,
  );

  Future<Map<String, dynamic>?> readCache(String key) =>
      cache.getData<Map<String, dynamic>>(key: key, fromJson: (j) => j);

  setUpAll(() => SharedPreferences.setMockInitialValues({}));

  test('is signed in when a token is stored', () async {
    await TokenStorage().saveToken('t1');

    expect(await repo.isSignedIn(), isTrue);
  });

  test('is signed out when no token is stored', () async {
    await TokenStorage().clearToken();

    expect(await repo.isSignedIn(), isFalse);
  });

  test('signOut removes the token', () async {
    await TokenStorage().saveToken('t1');

    await repo.signOut();

    expect(await repo.isSignedIn(), isFalse);
  });

  test(
    "signOut forgets the previous user's cached profile and bookmarks",
    () async {
      for (final key in [
        CacheKeys.userProfile,
        CacheKeys.userStats,
        CacheKeys.bookmarks,
        CacheKeys.bookmarkCollections,
      ]) {
        await seedCache(key);
      }
      await seedCache(CacheKeys.libraryStatistics);

      await repo.signOut();

      expect(await readCache(CacheKeys.userProfile), isNull);
      expect(await readCache(CacheKeys.userStats), isNull);
      expect(await readCache(CacheKeys.bookmarks), isNull);
      expect(await readCache(CacheKeys.bookmarkCollections), isNull);
      // Shared, non-personal data stays cached.
      expect(await readCache(CacheKeys.libraryStatistics), isNotNull);
    },
  );

  test(
    'a cache that cannot be cleared fails sign-out and keeps the session',
    () async {
      await TokenStorage().saveToken('t1');
      final repo = SessionRepoImpl(TokenStorage(), _UnclearableCache());

      final result = await repo.signOut();

      expect((result as ApiFailure).failure, isA<CacheFailure>());
      expect(await repo.isSignedIn(), isTrue);
    },
  );

  test('a token that cannot be removed fails sign-out', () async {
    final repo = SessionRepoImpl(_StuckTokenStorage(), cache);

    final result = await repo.signOut();

    expect((result as ApiFailure).failure, isA<CacheFailure>());
  });
}
