import 'package:mishkat_almasabih/features/authentication/login/data/models/login_response_body.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final LoginResponseBody loginResponseBody;
  LoginSuccess(this.loginResponseBody);
}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

class LogoutLoading extends LoginState {}

class LogoutSuccess extends LoginState {}

class LogoutError extends LoginState {
  final String message;
  LogoutError(this.message);
}

class GoogleLoginInitial extends LoginState {}

class GoogleLoginLoading extends LoginState {}

class GoogleLoginSuccess extends LoginState {
  final LoginResponseBody loginResponseBody;
  GoogleLoginSuccess(this.loginResponseBody);
}
