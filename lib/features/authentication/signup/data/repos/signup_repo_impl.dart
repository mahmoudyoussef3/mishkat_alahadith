import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';

import '../../domain/repos/signup_repo.dart';
import '../models/sign_up_request_body.dart';

class SignupRepoImpl implements SignupRepo {
  final ApiService _apiService;

  SignupRepoImpl(this._apiService);

  @override
  Future<ApiResult<void>> signup({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      await _apiService.signup(
        SignupRequestBody(username: username, email: email, password: password),
      );
      return const ApiResult.success(null);
    } catch (error) {
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }
}
