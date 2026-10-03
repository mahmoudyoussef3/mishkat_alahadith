import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/user_profile.dart';
import '../repos/profile_repo.dart';

class UpdateProfileUseCase {
  final ProfileRepo _repo;

  UpdateProfileUseCase(this._repo);

  Future<ApiResult<UserProfile>> call({
    required String username,
    String? avatarPath,
  }) => _repo.updateProfile(username: username, avatarPath: avatarPath);
}
