import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ScreenUtil not used directly after refactor
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/widgets/loading_progress_indicator.dart';

import '../../../../../core/helpers/functions.dart';
import '../../../../../core/routing/routes.dart';
import '../../../../../core/theming/colors.dart';
import '../../../../../core/widgets/app_text_button.dart';
import '../../logic/signup_cubit.dart';
import '../../../../../core/theming/auth_styles.dart';

class SignupBlocListener extends StatelessWidget {
  const SignupBlocListener({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SignupCubit, SignupState>(
      listenWhen:
          (previous, current) =>
              current is SignupLoading ||
              current is SignupSuccess ||
              current is SignupError,
      listener: (context, state) {
        if (state is SignupLoading) {
          showDialog(
            context: context,
            builder: (context) => loadingProgressIndicator(),
          );
        } else if (state is SignupSuccess) {
          context.pop();
          showSuccessDialog(context);
        } else if (state is SignupError) {
          setupErrorState(context, state.errorMessage);
        }
      },

      child: AppTextButton(
            backgroundColor: ColorsManager.primaryGreen,
            buttonText: 'إنشاء الحساب',

            onPressed: () {
              if (context
                  .read<SignupCubit>()
                  .formKey
                  .currentState!
                  .validate()) {
                context.read<SignupCubit>().emitSignUpStates();
              }
            },

            textStyle: AuthTextStyles.primaryButtonText,
          )
          .animate()
          .fadeIn(delay: 900.ms, duration: 300.ms)
          .scale(begin: const Offset(0.9, 0.9)),
    );
  }

  void showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تم التسجيل بنجاح'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('تم إنشاء حسابك بنجاح. استمتع بتجربتك الجديدة!'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: ColorsManager.primaryGreen,
                  disabledForegroundColor: Colors.grey.withOpacity(0.38),
                ),
                onPressed: () {
                  context.pushNamed(Routes.loginScreen);
                },
                child: const Text('استمرار'),
              ),
            ],
          ),
        );
      },
    );
  }
}
