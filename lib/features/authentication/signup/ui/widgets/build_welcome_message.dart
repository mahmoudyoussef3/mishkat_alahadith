import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// ColorsManager not used directly; using AuthTextStyles instead
import '../../../../../core/theming/auth_styles.dart';
class BuildWelcomeMessage extends StatelessWidget {
  const BuildWelcomeMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'انضم إلي مشكاة ',
          style: AuthTextStyles.headerTitle.copyWith(fontSize: 22.sp),
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.3),

        SizedBox(height: 8.h),

        Text(
          'أنشئ حسابك وابدأ رحلتك مع الأحاديث والعلوم الإسلامية',
          style: AuthTextStyles.headerSubtitle.copyWith(fontSize: 15.sp),
        ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.3),
      ],
    );
  }
}
