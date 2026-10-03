import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/authentication/signup/data/models/sign_up_request_body.dart';
import 'package:mishkat_almasabih/features/authentication/signup/data/repo/signup_repo.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final SignupRepo _signupRepo;

  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final TextEditingController userNameController = TextEditingController();

  SignupCubit(this._signupRepo) : super(SignupInitial());

  Future<void> emitSignUpStates() async {
    emit(SignupLoading());
    final response = await _signupRepo.signup(
      SignupRequestBody(
        email: emailController.text,
        password: passwordController.text,
        username: userNameController.text,
      ),
    );

    response.fold(
      (error) => emit(SignupError(error.getAllErrorMessages())),
      (data) => emit(SignupSuccess()),
    );
  }
}
