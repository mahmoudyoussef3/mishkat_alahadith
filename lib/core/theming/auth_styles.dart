import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';
import 'styles.dart';

/// AuthTextStyles centralizes text styles for Authentication flows.
/// Uses Amiri for Arabic text and aligns with global TextStyles.
class AuthTextStyles {
  AuthTextStyles._();

  /// Header title (login/signup).
  static TextStyle headerTitle = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryText,
    fontFamily: 'Amiri',
  );

  /// Header subtitle.
  static TextStyle headerSubtitle = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: ColorsManager.secondaryText,
    height: 1.4,
    fontFamily: 'Amiri',
  );

  /// Card label text (e.g., Google, guest).
  static TextStyle cardLabel = TextStyle(
    color: ColorsManager.darkGray,
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    fontFamily: 'Amiri',
  );

  /// Terms and conditions (reusing global legacy styles where appropriate).
  static TextStyle termsGray = TextStyles.bodySmall.copyWith(
    color: ColorsManager.gray,
    height: 1.5,
    fontFamily: 'Amiri',
  );

  static TextStyle termsLink = TextStyles.bodySmall.copyWith(
    color: ColorsManager.darkPurple,
    fontWeight: FontWeight.w500,
    fontFamily: 'Amiri',
  );

  /// Small prompt text preceding action links.
  static TextStyle prompt14 = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: ColorsManager.secondaryText,
    fontFamily: 'Amiri',
  );

  /// Action link style for login/signup navigation.
  static TextStyle actionLink14(Color color) => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: color,
        fontFamily: 'Amiri',
      );

  /// Input hint style for auth forms.
  static TextStyle inputHint = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: ColorsManager.secondaryText,
    fontFamily: 'Amiri',
  );

  /// Primary button text for auth actions.
  static TextStyle primaryButtonText = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: ColorsManager.white,
    fontFamily: 'Amiri',
  );

  /// Password validation item style.
  static TextStyle validationText({required bool validated}) => TextStyle(
        fontSize: 13.sp,
        color: validated ? ColorsManager.gray : ColorsManager.darkPurple,
        fontFamily: 'Amiri',
      );
}
