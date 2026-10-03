import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
// ScreenUtil not used directly in this file
import 'package:mishkat_almasabih/core/helpers/extensions.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart' show Routes;
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/auth_styles.dart';

class DontHaveAccountText extends StatelessWidget {
  const DontHaveAccountText({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('ليس لديك حساب ؟ ', style: AuthTextStyles.prompt14),
        TextButton(
          onPressed: () {
            context.pushNamed(Routes.signupScreen);
          },
          child: Text(
            'أنشئ حساب',
            style: AuthTextStyles.actionLink14(ColorsManager.primaryGreen),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 2600.ms, duration: 600.ms);
  }
}
