import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

class HadithTextStyles {
  HadithTextStyles._();

  static TextStyle get headerCategoryTitle => TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeight.w700,
    color: ColorsManager.primaryText,
    fontFamily: 'Amiri',
  );

  static TextStyle gradeLabel(Color gradeColor) => TextStyle(
    color: gradeColor,
    fontWeight: FontWeight.w800,
    fontSize: 16.sp,
    fontFamily: 'Amiri',
  );

  static TextStyle get hadithArabic => TextStyle(
    fontFamily: 'Amiri',
    color: ColorsManager.primaryText,
    fontSize: 17.sp,
    height: 1.8,
    fontWeight: FontWeight.w500,
  );

  static TextStyle pillLabel(Color textColor, {double? fontSize}) => TextStyle(
    color: textColor,
    fontWeight: FontWeight.w600,
    fontSize: (fontSize ?? 12.sp),
    fontFamily: 'Amiri',
  );

  static TextStyle get emptyTitle => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w800,
    color: ColorsManager.primaryText,
    fontFamily: 'Amiri',
  );

  static TextStyle get emptySubtitle => TextStyle(
    fontSize: 16.sp,
    color: ColorsManager.secondaryText,
    fontFamily: 'Amiri',
  );
}
