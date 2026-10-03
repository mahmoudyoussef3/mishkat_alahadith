import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class DailyHadithTextStyles {
  static TextStyle get snackText => TextStyle(
    color: ColorsManager.white,
  );

  static TextStyle get hadithText => TextStyle(
    fontSize: 20.sp,
    fontFamily: 'Amiri',
    height: 1.8,
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get labelChip => TextStyle(
    color: ColorsManager.primaryPurple,
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle tabLabel({required bool isSelected}) {
    return TextStyle(
      fontSize: isSelected ? 15.sp : 14.sp,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      color: isSelected ? Colors.white : ColorsManager.primaryPurple,
    );
  }

  static TextStyle get hadithTitle => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryPurple,
  );

  static TextStyle get actionLabel => TextStyle(
    fontSize: 13.sp,
    color: ColorsManager.darkGray,
  );

  static TextStyle get attribution => TextStyle(
    fontSize: 16,
    color: ColorsManager.accentPurple,
    fontStyle: FontStyle.italic,
  );

  static TextStyle gradeLabel(Color color) {
    return TextStyle(color: color, fontWeight: FontWeight.bold);
  }

  static TextStyle get explanation => TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w500,
    color: ColorsManager.primaryText,
    height: 1.6,
  );

  static TextStyle get hintNumber => TextStyle(
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryText,
  );

  static TextStyle get hintText => TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w500,
    color: ColorsManager.primaryText,
  );

  static TextStyle get wordStyle => TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w700,
    color: ColorsManager.darkPurple,
  );

  static TextStyle get colonStyle => TextStyle(
    fontWeight: FontWeight.bold,
    color: ColorsManager.darkPurple,
  );

  static TextStyle get meaningStyle => TextStyle(
    fontSize: 15,
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w500,
    color: ColorsManager.primaryText,
  );

  static TextStyle get fabLabel => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.white,
  );
}
