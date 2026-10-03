import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/user_profile.dart';
import '../entities/user_stats.dart';

abstract class ProfileRepo {
  Future<UserProfile?> getCachedProfile();

  Future<ApiResult<UserProfile>> getProfile();

  Future<ApiResult<UserStats>> getStats();

  Future<ApiResult<UserProfile>> updateProfile({
    required String username,
    String? avatarPath,
  });
}
