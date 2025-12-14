import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/authentication/login/data/models/login_request_body.dart';
import 'package:mishkat_almasabih/features/authentication/login/data/repo/login_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginRepo _loginRepo;

  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginCubit(this._loginRepo) : super(LoginInitial());

  Future<void> emitLoginStates() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    emit(LoginLoading());
    final response = await _loginRepo.login(
      LoginRequestBody(
        email: emailController.text,
        password: passwordController.text,
      ),
    );

    response.fold(
      (error) => emit(LoginError(error.getAllErrorMessages())),
      (data) async {
        await sharedPreferences.setString("token", data.token!);
        log("📌 Saved token: ${data.token}");
        emit(LoginSuccess(data));
      },
    );
  }

  /// Google login
  Future<void> emitGoogleLoginStates() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    emit(LoginLoading());
    final response = await _loginRepo.googleLogin();

    response.fold(
      (error) => emit(LoginError(error.getAllErrorMessages())),
      (data) async {
        log("📌 Google login token: ${data.token}");
        emit(LoginSuccess(data));
      },
    );
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }
}
