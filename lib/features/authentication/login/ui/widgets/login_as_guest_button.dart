import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/auth_styles.dart';
import 'package:mishkat_almasabih/core/theming/auth_decorations.dart';

class LoginAsGuestButton extends StatelessWidget {
  final VoidCallback onTap;

  const LoginAsGuestButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: ColorsManager.white,
        elevation: 5,
        shape:
            (AuthDecorations.socialCardShape().shape
                as RoundedRectangleBorder?),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('الدخول كزائر', style: AuthTextStyles.cardLabel),
              SizedBox(width: 12.w),
              const FaIcon(
                FontAwesomeIcons.userSecret,
                color: ColorsManager.darkGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
