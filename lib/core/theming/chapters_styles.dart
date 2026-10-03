import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';
import 'styles.dart';

class ChaptersTextStyles {
  static TextStyle get numberLabel => TextStyle(
    color: ColorsManager.purpleText,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get chapterTitle => TextStyle(
    color: ColorsManager.primaryText,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static TextStyle get statsTitle => TextStyles.titleMedium.copyWith(
    color: ColorsManager.white.withOpacity(0.9),
    fontWeight: FontWeight.w600,
  );

  static TextStyle get statsValue => TextStyles.headlineLarge.copyWith(
    color: ColorsManager.white,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get emptyTitle => TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: ColorsManager.darkPurpleText,
  );

  static TextStyle get emptySubtitle => TextStyle(
    fontSize: 14,
    color: ColorsManager.secondaryText,
  );
}
