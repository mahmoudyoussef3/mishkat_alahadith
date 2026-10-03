import 'package:mishkat_almasabih/core/networking/api_result.dart';

abstract class SignupRepo {
  Future<ApiResult<void>> signup({
    required String username,
    required String email,
    required String password,
  });
}
