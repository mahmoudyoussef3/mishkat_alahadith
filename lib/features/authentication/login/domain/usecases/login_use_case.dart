import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/auth_session.dart';
import '../repos/login_repo.dart';

class LoginUseCase {
  final LoginRepo _repo;

  LoginUseCase(this._repo);

  Future<ApiResult<AuthSession>> call({
    required String email,
    required String password,
  }) => _repo.login(email: email, password: password);
}
