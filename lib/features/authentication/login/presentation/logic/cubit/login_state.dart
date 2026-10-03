import 'package:mishkat_almasabih/features/authentication/login/domain/entities/auth_session.dart';

abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final AuthSession session;
  LoginSuccess(this.session);
}

class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}
