import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/auth_session.dart';

abstract class LoginRepo {
  Future<ApiResult<AuthSession>> login({
    required String email,
    required String password,
  });

  Future<ApiResult<AuthSession>> loginWithGoogle();
}
