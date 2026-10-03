import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/session_repo.dart';

class SignOutUseCase {
  final SessionRepo _repo;

  SignOutUseCase(this._repo);

  Future<ApiResult<void>> call() => _repo.signOut();
}
