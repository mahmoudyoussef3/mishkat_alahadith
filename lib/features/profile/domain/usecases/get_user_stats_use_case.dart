import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/user_stats.dart';
import '../repos/profile_repo.dart';

class GetUserStatsUseCase {
  final ProfileRepo _repo;

  GetUserStatsUseCase(this._repo);

  Future<ApiResult<UserStats>> call() => _repo.getStats();
}
