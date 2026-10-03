import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/app_palette.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingTextStyles {
  static TextStyle appNameStyle(Color color) {
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  static TextStyle get skipButtonStyle => TextStyle(
    color: AppPalette.light.secondaryText,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle pageTitleStyle(bool isSmallScreen) {
    return TextStyle(
      fontSize: isSmallScreen ? 20.sp : 24.sp,
      fontWeight: FontWeight.bold,
      color: AppPalette.light.primaryText,
      height: 1.3,
    );
  }

  static TextStyle pageSubtitleStyle(bool isSmallScreen) {
    return TextStyle(
      fontSize: isSmallScreen ? 14.sp : 16.sp,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
  }

  static TextStyle pageDescriptionStyle(bool isSmallScreen) {
    return TextStyle(
      fontSize: isSmallScreen ? 13.sp : 15.sp,
      color: AppPalette.light.secondaryText,
      height: 1.5,
      fontWeight: FontWeight.w400,
    );
  }

  static TextStyle get backButtonStyle => TextStyle(
    color: AppPalette.light.secondaryText,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle nextButtonStyle = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
  );
}
