import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theming/colors.dart';
import '../../../../../core/widgets/app_text_form_field.dart';
import '../../logic/signup_cubit.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  bool isPasswordObscureText = false;
  bool isPasswordConfirmationObscureText = false;

  late TextEditingController passwordController;
  @override
  void initState() {
    super.initState();
    passwordController = context.read<SignupCubit>().passwordController;
  }

  @override
  Widget build(BuildContext context) {
    var signupCubit = context.read<SignupCubit>();

    return Form(
      key: context.read<SignupCubit>().formKey,
      child: Column(
        children: [
          AppTextFormField(
                controller: signupCubit.userNameController,

                backgroundColor: ColorsManager.lightGray,
                suffixIcon: Icon(
                  Icons.person,
                  color: ColorsManager.primaryGreen,
                ),
                hintText: 'الاسم الكامل',
                hintStyle: TextStyle(color: Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال الاسم الكامل';
                  }
                  if (value.length < 3) {
                    return 'الاسم يجب أن يكون 3 أحرف على الأقل';
                  }
                  return null;
                },
              )
              .animate()
              .fadeIn(delay: 500.ms, duration: 300.ms)
              .slideX(begin: -0.3),

          SizedBox(height: 16.h),

          AppTextFormField(
                hintStyle: TextStyle(color: Colors.black),

                backgroundColor: ColorsManager.lightGray,
                suffixIcon: Icon(
                  Icons.email,
                  color: ColorsManager.primaryGreen,
                ),
                controller: signupCubit.emailController,
                hintText: 'البريد الإلكتروني',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال البريد الإلكتروني';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'يرجى إدخال بريد إلكتروني صحيح';
                  }
                  return null;
                },
              )
              .animate()
              .fadeIn(delay: 600.ms, duration: 300.ms)
              .slideX(begin: -0.3),

          SizedBox(height: 16.h),

          AppTextFormField(
                hintStyle: TextStyle(color: Colors.black),

                backgroundColor: ColorsManager.lightGray,
                controller: signupCubit.passwordController,
                hintText: 'كلمة المرور',
                isObscureText: !isPasswordObscureText,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordObscureText
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: ColorsManager.primaryGreen,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordObscureText = !isPasswordObscureText;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال كلمة المرور';
                  }
                  if (value.length < 6) {
                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                  }
                  return null;
                },
              )
              .animate()
              .fadeIn(delay: 700.ms, duration: 300.ms)
              .slideX(begin: -0.3),

          SizedBox(height: 16.h),

          AppTextFormField(
                hintStyle: TextStyle(color: Colors.black),

                backgroundColor: ColorsManager.lightGray,
                controller: signupCubit.confirmPasswordController,
                hintText: 'تأكيد كلمة المرور',
                isObscureText: !isPasswordConfirmationObscureText,
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordConfirmationObscureText
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: ColorsManager.primaryGreen,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordConfirmationObscureText =
                          !isPasswordConfirmationObscureText;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى تأكيد كلمة المرور';
                  }
                  if (value != signupCubit.passwordController.text) {
                    return 'كلمة المرور غير متطابقة';
                  }
                  return null;
                },
              )
              .animate()
              .fadeIn(delay: 800.ms, duration: 300.ms)
              .slideX(begin: -0.3),
        ],
      ),
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }
}
