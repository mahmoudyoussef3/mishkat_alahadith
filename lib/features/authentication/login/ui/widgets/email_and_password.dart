import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theming/colors.dart';
import '../../../../../core/theming/auth_styles.dart';
import '../../../../../core/widgets/app_text_form_field.dart';
import '../../logic/cubit/login_cubit.dart';

class EmailAndPassword extends StatefulWidget {
  const EmailAndPassword({super.key});

  @override
  State<EmailAndPassword> createState() => _EmailAndPasswordState();
}

class _EmailAndPasswordState extends State<EmailAndPassword> {
  bool isObscureText = false;

  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    passwordController = context.read<LoginCubit>().passwordController;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: context.read<LoginCubit>().formKey,
      child: Column(
        children: [
          // Email Field
          AppTextFormField(
                backgroundColor: ColorsManager.lightGray,
                suffixIcon: Icon(
                  Icons.email,
                  color: ColorsManager.primaryGreen,
                ),
                controller: context.read<LoginCubit>().emailController,
                hintText: 'البريد الإلكتروني',
                hintStyle: AuthTextStyles.inputHint,
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
              .fadeIn(delay: 500.ms, duration: 300.ms)
              .slideX(begin: -0.3),

          SizedBox(height: 20.h),

          // Password Field
          AppTextFormField(
                backgroundColor: ColorsManager.lightGray,
                hintStyle: AuthTextStyles.inputHint,

                controller: context.read<LoginCubit>().passwordController,
                hintText: 'كلمة المرور',
                isObscureText: !isObscureText,
                suffixIcon: IconButton(
                  icon: Icon(
                    isObscureText ? Icons.visibility : Icons.visibility_off,
                    color: ColorsManager.primaryGreen,
                  ),
                  onPressed: () {
                    setState(() {
                      isObscureText = !isObscureText;
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
              .fadeIn(delay: 600.ms, duration: 300.ms)
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
