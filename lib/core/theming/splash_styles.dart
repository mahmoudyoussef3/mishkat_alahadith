import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class SplashTextStyles {
  static TextStyle get appNameArabic => TextStyle(
    fontFamily: 'Cairo',
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.white,
    letterSpacing: 1.0,
    shadows: [
      Shadow(
        color: ColorsManager.black.withOpacity(0.3),
        offset: const Offset(0, 2),
        blurRadius: 4,
      ),
    ],
  );

  static TextStyle get appDescription => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: ColorsManager.white.withOpacity(0.9),
    height: 1.6,
    fontFamily: 'Amiri',
  );

  static const String appNameText = 'مشكاة الأحاديث';

  static const String appDescriptionText =
      'اكتشف آلاف الأحاديث الموثوقة مع ميزات بحث ذكية وحفظ المفضلة. ابدأ رحلتك في التعلم الإسلامي الآن';
}
