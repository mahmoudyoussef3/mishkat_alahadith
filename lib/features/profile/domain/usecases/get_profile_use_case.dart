import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/user_profile.dart';
import '../repos/profile_repo.dart';

class GetProfileUseCase {
  final ProfileRepo _repo;

  GetProfileUseCase(this._repo);

  Future<ApiResult<UserProfile>> call() => _repo.getProfile();
}
