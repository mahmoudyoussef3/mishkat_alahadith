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
    fontFamily: 'Almarai',
  );

  static TextStyle get headerSubtitle => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    color: ColorsManager.secondaryText,
    height: 1.4,
    fontFamily: 'Almarai',
  );

  static TextStyle get cardLabel => TextStyle(
    color: ColorsManager.darkGray,
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    fontFamily: 'Almarai',
  );

  static TextStyle get termsGray => TextStyles.bodySmall.copyWith(
    color: ColorsManager.gray,
    height: 1.5,
    fontFamily: 'Almarai',
  );

  static TextStyle get termsLink => TextStyles.bodySmall.copyWith(
    color: ColorsManager.darkPurpleText,
    fontWeight: FontWeight.w500,
    fontFamily: 'Almarai',
  );

  static TextStyle get prompt14 => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: ColorsManager.secondaryText,
    fontFamily: 'Almarai',
  );

  static TextStyle actionLink14(Color color) => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: color,
    fontFamily: 'Almarai',
  );

  static TextStyle get inputHint => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: ColorsManager.secondaryText,
    fontFamily: 'Cairo',
  );

  static TextStyle get primaryButtonText => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: ColorsManager.white,
    fontFamily: 'Almarai',
  );

  static TextStyle validationText({required bool validated}) => TextStyle(
    fontSize: 13.sp,
    color: validated ? ColorsManager.gray : ColorsManager.darkPurpleText,
    fontFamily: 'Almarai',
  );
}
