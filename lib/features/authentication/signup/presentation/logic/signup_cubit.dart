import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/features/authentication/signup/domain/usecases/signup_use_case.dart';

part 'signup_state.dart';

class SignupCubit extends Cubit<SignupState> {
  final SignupUseCase _signup;

  final formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final TextEditingController userNameController = TextEditingController();

  SignupCubit(this._signup) : super(SignupInitial());

  Future<void> emitSignUpStates() async {
    emit(SignupLoading());
    final response = await _signup(
      email: emailController.text,
      password: passwordController.text,
      username: userNameController.text,
    );

    response.when(
      success: (_) => emit(SignupSuccess()),
      failure: (failure) => emit(SignupError(failure.message)),
    );
  }

  @override
  Future<void> close() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    userNameController.dispose();
    return super.close();
  }
}
