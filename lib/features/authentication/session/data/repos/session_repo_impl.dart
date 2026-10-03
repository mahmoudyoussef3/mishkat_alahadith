import 'dart:developer';

import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';

import '../../domain/repos/session_repo.dart';

class SessionRepoImpl implements SessionRepo {
  static const List<String> _userScopedCacheKeys = [
    CacheKeys.userProfile,
    CacheKeys.userStats,
    CacheKeys.bookmarks,
    CacheKeys.bookmarkCollections,
  ];

  final TokenStorage _tokenStorage;
  final GenericCacheService _cacheService;

  SessionRepoImpl(this._tokenStorage, this._cacheService);

  @override
  Future<bool> isSignedIn() async {
    try {
      return await _tokenStorage.getToken() != null;
    } catch (error) {
      log('Unable to read the session token: $error');
      return false;
    }
  }

  @override
  Future<ApiResult<void>> signOut() async {
    try {
      for (final key in _userScopedCacheKeys) {
        if (!await _cacheService.clearCache(key)) {
          return const ApiResult.failure(CacheFailure());
        }
      }
      if (!await _tokenStorage.clearToken()) {
        return const ApiResult.failure(CacheFailure());
      }
      return const ApiResult.success(null);
    } catch (error) {
      log('Sign-out failed: $error');
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }
}
