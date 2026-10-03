import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mishkat_almasabih/core/helpers/extensions.dart';

import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/auth_styles.dart';

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
