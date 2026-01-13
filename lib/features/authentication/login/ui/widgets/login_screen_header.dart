import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/colors.dart';
import '../../../../../core/theming/auth_decorations.dart';
import '../../../../../core/theming/auth_styles.dart';

class LoginScreenHeader extends StatelessWidget {
  const LoginScreenHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Logo
        Container(
              width: 100.w,
              height: 100.w,
              decoration: AuthDecorations.logoCircle(),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            )
            .animate()
            .scale(begin: const Offset(0.8, 0.8), duration: 400.ms)
            .then()
            .shimmer(
              duration: 800.ms,
              color: ColorsManager.white.withOpacity(0.3),
            ),

        SizedBox(height: 20.h),

        // App Name
        Text(
          'مرحباً بك مرة أخرى',
          style: AuthTextStyles.headerTitle,
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.3),

        SizedBox(height: 8.h),

        Text(
          "سجل دخولك وابدء رحلتك مع الأحاديث والعلوم الإسلامية",
          style: AuthTextStyles.headerSubtitle,
        ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.3),
      ],
    );
  }
}
