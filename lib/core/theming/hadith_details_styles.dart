import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class HadithDetailsTextStyles {
  static TextStyle get snackText => TextStyle(
    color: ColorsManager.white,
  );

  static TextStyle get labelChip => TextStyle(
    color: ColorsManager.primaryPurple,
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get hadithText => TextStyle(
    fontSize: 20.sp,
    height: 1.8,
    color: ColorsManager.primaryText,
    fontFamily: 'Amiri',
    fontWeight: FontWeight.w500,
  );

  static TextStyle get bookLabel => TextStyle(
    fontSize: 14.sp,
    color: ColorsManager.darkGray,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get bookValue => TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryText,
  );

  static TextStyle gradeLabel(Color color) {
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  static TextStyle get navigationLabel => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryPurple,
  );

  static TextStyle get headerMain => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: ColorsManager.primaryText,
  );

  static TextStyle get headerSub => TextStyle(
    fontSize: 13.sp,
    color: ColorsManager.secondaryText,
  );

  static TextStyle get fabLabel => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.white,
  );

  static TextStyle get actionLabel => TextStyle(
    fontSize: 13.sp,
    color: ColorsManager.darkGray,
  );
}
