import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theming/colors.dart';
import '../../../../../core/theming/auth_decorations.dart';
class BuildSignupHeader extends StatelessWidget {
  const BuildSignupHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80.w,
          height: 80.w,
          decoration: AuthDecorations.logoCircle(),
          child: Padding(
            padding: EdgeInsets.all(16.w),
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
      ],
    );
  }
}
