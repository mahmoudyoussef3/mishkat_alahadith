import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/decorations.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mishkat_almasabih/features/about_us/ui/widgets/social_icons_row.dart';

class BuildMishkatInfSection extends StatelessWidget {
  const BuildMishkatInfSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 20.w),
        decoration: BoxDecoration(
          gradient: Decorations.primaryDiagonalGradient,
          borderRadius: Decorations.verticalTop(30.r),
        ),
        child: Column(
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: Decorations.circleWhiteShadow,
              child: Padding(
                padding: EdgeInsets.all(18.w),
                child: Image.asset(
                  'assets/images/app_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'منصة رقمية متكاملة لدراسة الأحاديث النبوية الشريفة مع تحليل ذكي وفوائد عملية',
              style: TextStyles.bodyMedium.copyWith(
                color: ColorsManager.secondaryBackground,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            SocialIconsRow(),
            SizedBox(height: 10.h),
            Divider(color: ColorsManager.gray, endIndent: 50.w, indent: 50.w),
            SizedBox(height: 10.h),

            Text(
              "© جميع الحقوق محفوظة لتطبيق مشكاة الأحاديث 2026",
              style: TextStyles.labelSmall.copyWith(
                color: ColorsManager.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
