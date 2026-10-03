import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class SendSuggestionTextStyles {
  static TextStyle title(bool isTablet) {
    return TextStyle(
      fontSize: isTablet ? 26.sp : 22.sp,
      fontWeight: FontWeight.bold,
      color: ColorsManager.purpleText,
      height: 1.3,
    );
  }

  static TextStyle subtitle(bool isTablet) {
    return TextStyle(
      fontSize: isTablet ? 20.sp : 18.sp,
      fontWeight: FontWeight.w600,
      color: ColorsManager.primaryPurple.withOpacity(0.7),
      height: 1.3,
    );
  }

  static TextStyle description(bool isTablet) {
    return TextStyle(
      fontSize: isTablet ? 15.sp : 14.sp,
      color: ColorsManager.gray,
      height: 1.5,
    );
  }

  static TextStyle textFieldHint(bool isTablet) {
    return TextStyle(color: ColorsManager.gray, fontSize: isTablet ? 15.sp : 14.sp);
  }

  static TextStyle textFieldInput(bool isTablet) {
    return TextStyle(fontSize: isTablet ? 16.sp : 15.sp, height: 1.6);
  }

  static TextStyle get textFieldCounter => TextStyle(
    fontSize: 12.sp,
    color: ColorsManager.gray,
  );

  static TextStyle privacyNote(bool isTablet) {
    return TextStyle(
      fontSize: isTablet ? 12.sp : 11.sp,
      color: ColorsManager.gray.withOpacity(0.8),
      fontWeight: FontWeight.w500,
    );
  }

  static TextStyle sendButtonText(bool isTablet) {
    return TextStyle(
      fontSize: isTablet ? 17.sp : 16.sp,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle sendButtonLoadingText(bool isTablet) {
    return TextStyle(
      fontSize: isTablet ? 17.sp : 16.sp,
      fontWeight: FontWeight.bold,
    );
  }

  static TextStyle get footerNote => TextStyle(
    fontSize: 12.sp,
    color: ColorsManager.gray.withOpacity(0.7),
  );

  static const TextStyle snackbarEmpty = TextStyle();

  static const TextStyle snackbarSuccess = TextStyle();

  static const TextStyle snackbarError = TextStyle();
}
