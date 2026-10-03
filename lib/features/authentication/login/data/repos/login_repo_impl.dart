import 'dart:developer';

import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/storage/token_storage.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/repos/login_repo.dart';
import '../datasources/google_auth_datasource.dart';
import '../models/login_request_body.dart';
import '../models/login_response_body.dart';

class LoginRepoImpl implements LoginRepo {
  static const String _googleCancelledMessage = 'تم إلغاء تسجيل الدخول';
  static const String _invalidCredentialsMessage =
      'البريد الإلكتروني أو كلمة المرور غير صحيحة';

  final ApiService _apiService;
  final GoogleAuthDataSource _googleAuth;
  final TokenStorage _tokenStorage;

  LoginRepoImpl(this._apiService, this._googleAuth, this._tokenStorage);

  @override
  Future<ApiResult<AuthSession>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.login(
        LoginRequestBody(email: email, password: password),
      );
      return _persistSession(response);
    } catch (error) {
      return ApiResult.failure(_loginFailure(error));
    }
  }

  Failure _loginFailure(Object error) {
    final failure = ErrorHandler.toFailure(error);
    if (failure is UnauthorizedFailure &&
        failure.message == FailureMessages.unauthorized) {
      return const UnauthorizedFailure(_invalidCredentialsMessage);
    }
    return failure;
  }

  @override
  Future<ApiResult<AuthSession>> loginWithGoogle() async {
    try {
      final idToken = await _googleAuth.signInAndGetIdToken();
      if (idToken == null) {
        return const ApiResult.failure(
          UnexpectedFailure(_googleCancelledMessage),
        );
      }
      final response = await _apiService.googleLogin({"token": idToken});
      return _persistSession(response);
    } catch (error) {
      log(error.toString());
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }

  Future<ApiResult<AuthSession>> _persistSession(
    LoginResponseBody response,
  ) async {
    final token = response.token;
    if (token == null || token.isEmpty) {
      return const ApiResult.failure(UnexpectedFailure());
    }
    await _tokenStorage.saveToken(token);
    return ApiResult.success(
      AuthSession(token: token, userName: response.userData?.userName),
    );
  }
}
