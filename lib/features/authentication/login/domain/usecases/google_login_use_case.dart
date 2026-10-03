import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/auth_session.dart';
import '../repos/login_repo.dart';

class GoogleLoginUseCase {
  final LoginRepo _repo;

  GoogleLoginUseCase(this._repo);

  Future<ApiResult<AuthSession>> call() => _repo.loginWithGoogle();
}
