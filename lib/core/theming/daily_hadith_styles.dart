import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class DailyHadithTextStyles {
  static TextStyle get snackText => TextStyle(
    color: ColorsManager.white,
  );

  static TextStyle get hadithText => TextStyles.readingLarge;

  static TextStyle get labelChip => TextStyle(
    color: ColorsManager.purpleText,
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle tabLabel({required bool isSelected}) {
    return TextStyle(
      fontSize: 14.sp,
      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
      color: isSelected ? Colors.white : ColorsManager.secondaryText,
    );
  }

  static TextStyle get hadithTitle => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: ColorsManager.purpleText,
  );

  static TextStyle get actionLabel => TextStyle(
    fontSize: 13.sp,
    color: ColorsManager.darkGray,
  );

  static TextStyle get attribution => TextStyles.attribution;

  static TextStyle gradeLabel(Color color) {
    return TextStyle(color: color, fontWeight: FontWeight.bold);
  }

  static TextStyle get explanation => TextStyles.explanationBody;

  static TextStyle get hintNumber => TextStyle(
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryText,
  );

  static TextStyle get hintText => TextStyles.explanationBody;

  static TextStyle get wordStyle => TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w700,
    color: ColorsManager.darkPurpleText,
  );

  static TextStyle get colonStyle => TextStyle(
    fontWeight: FontWeight.bold,
    color: ColorsManager.darkPurpleText,
  );

  static TextStyle get meaningStyle => TextStyles.explanationBody;

  static TextStyle get fabLabel => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.white,
  );
}
