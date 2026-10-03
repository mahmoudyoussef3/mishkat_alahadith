import 'package:dartz/dartz.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/authentication/signup/data/models/sign_up_response_body.dart';
import '../../../../../core/networking/api_error_handler.dart';
import '../../../../../core/networking/api_service.dart';
import '../models/sign_up_request_body.dart';

class SignupRepo {
  final ApiService _apiService;

  SignupRepo(this._apiService);

  Future<Either<ApiErrorModel, SignUpResponseBody>> signup(
    SignupRequestBody signupRequestBody,
  ) async {
    try {
      final response = await _apiService.signup(signupRequestBody);
      return Right(response);
    } catch (error) {
      return Left(ErrorHandler.handle(error));
    }
  }
}
