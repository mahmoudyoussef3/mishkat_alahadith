import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/signup_repo.dart';

class SignupUseCase {
  final SignupRepo _repo;

  SignupUseCase(this._repo);

  Future<ApiResult<void>> call({
    required String username,
    required String email,
    required String password,
  }) => _repo.signup(username: username, email: email, password: password);
}
