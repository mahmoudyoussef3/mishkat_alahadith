import '../entities/user_profile.dart';
import '../repos/profile_repo.dart';

class GetCachedProfileUseCase {
  final ProfileRepo _repo;

  GetCachedProfileUseCase(this._repo);

  Future<UserProfile?> call() => _repo.getCachedProfile();
}
