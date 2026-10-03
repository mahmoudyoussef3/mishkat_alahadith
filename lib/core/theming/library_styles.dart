import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart' as BaseStyles;

class LibraryTextStyles {
  static TextStyle get bookTitle => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryText,
  );

  static TextStyle get bookWriter => TextStyle(
    fontSize: 12.sp,
    color: ColorsManager.secondaryText,
  );

  static TextStyle get statText => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: ColorsManager.secondaryText,
  );

  static TextStyle get sectionHeader => BaseStyles.TextStyles.headlineMedium
      .copyWith(color: ColorsManager.primaryText, fontWeight: FontWeight.bold);

  static TextStyle get headerTitleStyle => BaseStyles.TextStyles.headlineMedium
      .copyWith(color: ColorsManager.primaryText, fontWeight: FontWeight.bold);

  static TextStyle get headerDescriptionStyle => BaseStyles.TextStyles.bodyMedium
      .copyWith(color: ColorsManager.secondaryText);
}
