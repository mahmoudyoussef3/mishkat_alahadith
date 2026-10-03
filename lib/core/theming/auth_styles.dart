import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';
import 'styles.dart';

class AuthTextStyles {
  AuthTextStyles._();

  static TextStyle get headerTitle => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryText,
    fontFamily: 'Amiri',
  );

  static TextStyle get headerSubtitle => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: ColorsManager.secondaryText,
    height: 1.4,
    fontFamily: 'Amiri',
  );

  static TextStyle get cardLabel => TextStyle(
    color: ColorsManager.darkGray,
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    fontFamily: 'Amiri',
  );

  static TextStyle get termsGray => TextStyles.bodySmall.copyWith(
    color: ColorsManager.gray,
    height: 1.5,
    fontFamily: 'Amiri',
  );

  static TextStyle get termsLink => TextStyles.bodySmall.copyWith(
    color: ColorsManager.darkPurple,
    fontWeight: FontWeight.w500,
    fontFamily: 'Amiri',
  );

  static TextStyle get prompt14 => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: ColorsManager.secondaryText,
    fontFamily: 'Amiri',
  );

  static TextStyle actionLink14(Color color) => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: color,
    fontFamily: 'Amiri',
  );

  static TextStyle get inputHint => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: ColorsManager.secondaryText,
    fontFamily: 'Amiri',
  );

  static TextStyle get primaryButtonText => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: ColorsManager.white,
    fontFamily: 'Amiri',
  );

  static TextStyle validationText({required bool validated}) => TextStyle(
    fontSize: 13.sp,
    color: validated ? ColorsManager.gray : ColorsManager.darkPurple,
    fontFamily: 'Amiri',
  );
}
