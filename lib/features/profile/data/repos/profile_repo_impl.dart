import 'dart:developer';
import 'dart:io';

import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/cache_fallback.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_stats.dart';
import '../../domain/repos/profile_repo.dart';
import '../mappers/profile_mapper.dart';
import '../models/stats_model.dart';
import '../models/user_response_model.dart';

class ProfileRepoImpl implements ProfileRepo {
  final ApiService _apiService;
  final TokenStorage _tokenStorage;
  final GenericCacheService _cacheService;

  ProfileRepoImpl(this._apiService, this._tokenStorage, this._cacheService);

  @override
  Future<UserProfile?> getCachedProfile() async {
    final cached = await _cacheService.getData<UserResponseModel>(
      key: CacheKeys.userProfile,
      fromJson: UserResponseModel.fromJson,
    );
    return cached?.toEntity();
  }

  @override
  Future<ApiResult<UserProfile>> getProfile() =>
      _cacheService.fetchWithStaleFallback<UserResponseModel, UserProfile>(
        key: CacheKeys.userProfile,
        fetch: () async {
          final token = await _tokenStorage.requireToken();
          return _apiService.getUserProfile(token);
        },
        toJson: (d) => d.withoutSecrets().toJson(),
        fromJson: UserResponseModel.fromJson,
        toEntity: (d) => d.toEntity(),
        cacheExpirationHours: 1,
      );

  @override
  Future<ApiResult<UserStats>> getStats() =>
      _cacheService.fetchWithStaleFallback<StatsModel, UserStats>(
        key: CacheKeys.userStats,
        fetch: () async {
          final token = await _tokenStorage.requireToken();
          return _apiService.getUserStats(token);
        },
        toJson: (d) => d.toJson(),
        fromJson: StatsModel.fromJson,
        toEntity: (d) => d.toEntity(),
        cacheExpirationHours: 1,
      );

  @override
  Future<ApiResult<UserProfile>> updateProfile({
    required String username,
    String? avatarPath,
  }) async {
    try {
      final token = await _tokenStorage.requireToken();
      final response = await _apiService.updateUserProfile(
        token,
        username,
        avatarPath == null ? null : File(avatarPath),
      );
      // So the edit is what shows offline, not the profile from before it.
      await _cacheService.saveData<UserResponseModel>(
        key: CacheKeys.userProfile,
        data: response.withoutSecrets(),
        toJson: (d) => d.toJson(),
        cacheExpirationHours: 1,
      );
      return ApiResult.success(response.toEntity());
    } catch (error) {
      log(error.toString());
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }
}
