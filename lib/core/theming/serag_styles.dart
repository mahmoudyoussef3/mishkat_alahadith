import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class SeragTextStyles {
  static const String headerTitle = "سراج";
  static const String headerDescription = "مساعد الحديث";

  static TextStyle get userMessage => TextStyle(
    color: Colors.white,
    fontSize: 15.sp,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get assistantMessage => TextStyle(
    color: ColorsManager.primaryText,
    fontSize: 15.sp,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle snackbarCopyMessage = TextStyle();

  static TextStyle get inputFieldText => TextStyle(
    fontSize: 15.sp,
    color: ColorsManager.primaryText,
  );

  static TextStyle get inputHintText => TextStyle(
    color: ColorsManager.secondaryText,
    fontSize: 15.sp,
  );

  static double sendButtonIconSize = 24.sp;

  static const TextStyle errorSnackbarText = TextStyle();

  static TextStyle get limitExceededSnackbar => TextStyle(
    color: ColorsManager.white,
    fontSize: 14.sp,
    height: 1.4,
  );

  static TextStyle get warningDisclaimer => TextStyle(
    fontSize: 11.sp,
    color: ColorsManager.secondaryText,
    fontStyle: FontStyle.italic,
  );

  static TextStyle get emptyStateMainText => TextStyle(
    fontSize: 16.sp,
    color: ColorsManager.secondaryText,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get emptyStateSubtitle => TextStyle(
    fontSize: 14.sp,
    color: ColorsManager.secondaryText.withOpacity(0.7),
  );

  static TextStyle get remainingQuestionsText => TextStyle(
    color: ColorsManager.purpleText,
    fontWeight: FontWeight.w600,
    fontSize: 14.sp,
  );

  static TextStyle get noAttemptsWarningText => TextStyle(
    color: ColorsManager.error,
    fontSize: 14,
    height: 1.4,
  );
}
