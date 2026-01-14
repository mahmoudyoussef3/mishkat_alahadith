import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

/// Splash Screen feature text styles
/// Extracted from splash_screen for consistent styling
class SplashTextStyles {
  // ==================== APP NAME SECTION ====================

  /// Arabic app name text style
  static TextStyle appNameArabic = TextStyle(
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

  /// App description text style
  static TextStyle appDescription = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: ColorsManager.white.withOpacity(0.9),
    height: 1.6,
    fontFamily: 'Amiri',
  );

  /// App name text
  static const String appNameText = 'مشكاة الأحاديث';

  /// App description text
  static const String appDescriptionText =
      'اكتشف آلاف الأحاديث الموثوقة مع ميزات بحث ذكية وحفظ المفضلة. ابدأ رحلتك في التعلم الإسلامي الآن';
}
