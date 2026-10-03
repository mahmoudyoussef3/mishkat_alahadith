import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/authentication/login/domain/usecases/google_login_use_case.dart';
import 'package:mishkat_almasabih/features/authentication/login/domain/usecases/login_use_case.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase _login;
  final GoogleLoginUseCase _googleLogin;

  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginCubit(this._login, this._googleLogin) : super(LoginInitial());

  Future<void> emitLoginStates() async {
    emit(LoginLoading());
    final response = await _login(
      email: emailController.text,
      password: passwordController.text,
    );

    response.when(
      success: (session) => emit(LoginSuccess(session)),
      failure: (failure) => emit(LoginError(failure.message)),
    );
  }

  Future<void> emitGoogleLoginStates() async {
    emit(LoginLoading());
    final response = await _googleLogin();

    response.when(
      success: (session) => emit(LoginSuccess(session)),
      failure: (failure) => emit(LoginError(failure.message)),
    );
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    return super.close();
  }
}
