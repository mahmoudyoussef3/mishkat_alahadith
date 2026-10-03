import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
// ScreenUtil no longer needed directly; sizes resolved via AuthTextStyles
import 'package:mishkat_almasabih/core/helpers/extensions.dart';

import '../../../../../core/routing/routes.dart';
import '../../../../../core/theming/colors.dart';
import '../../../../../core/theming/auth_styles.dart';

class AlreadyHaveAccount extends StatelessWidget {
  const AlreadyHaveAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('لديك حساب بالفعل؟ ', style: AuthTextStyles.prompt14),
        TextButton(
          onPressed: () {
            context.pushNamed(Routes.loginScreen);
          },
          child: Text(
            'تسجيل الدخول',
            style: AuthTextStyles.actionLink14(ColorsManager.primaryGreen),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 1100.ms, duration: 300.ms);
  }
}
