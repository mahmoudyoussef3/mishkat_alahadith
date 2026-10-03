import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/features/profile/data/models/stats_model.dart';
import 'package:mishkat_almasabih/features/profile/data/models/user_response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserResponseRepo {
  final ApiService apiService;
  final _cacheService = GenericCacheService.instance;

  UserResponseRepo(this.apiService);

  /// Get cached user profile
  Future<UserResponseModel?> getCachedProfile() async {
    return await _cacheService.getData<UserResponseModel>(
      key: CacheKeys.userProfile,
      fromJson: UserResponseModel.fromJson,
    );
  }

  /// Save user profile to cache
  Future<void> cacheProfile(UserResponseModel data) async {
    await _cacheService.saveData<UserResponseModel>(
      key: CacheKeys.userProfile,
      data: data,
      toJson: (d) => d.toJson(),
      cacheExpirationHours: 1, // Short cache for user data
    );
  }

  /// Get cached user stats
  Future<StatsModel?> getCachedStats() async {
    return await _cacheService.getData<StatsModel>(
      key: CacheKeys.userStats,
      fromJson: StatsModel.fromJson,
    );
  }

  /// Save user stats to cache
  Future<void> cacheStats(StatsModel data) async {
    await _cacheService.saveData<StatsModel>(
      key: CacheKeys.userStats,
      data: data,
      toJson: (d) => d.toJson(),
      cacheExpirationHours: 1,
    );
  }

  Future<Either<ApiErrorModel, UserResponseModel>> getUserProfile() async {
    try {
      final String token = await _getUserToken();
      final response = await apiService.getUserProfile(token);
      // Cache the response
      await cacheProfile(response);
      return Right(response);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<Either<ApiErrorModel, StatsModel>> getUserStats() async {
    try {
      final String token = await _getUserToken();
      final response = await apiService.getUserStats(token);
      // Cache the response
      await cacheStats(response);
      return Right(response);
    } catch (e) {
      return Left(ErrorHandler.handle(e));
    }
  }

  Future<String> _getUserToken() async {
    final sharedPref = await SharedPreferences.getInstance();
    final token = sharedPref.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception("No token found, user not logged in");
    }
    return token;
  }
}
