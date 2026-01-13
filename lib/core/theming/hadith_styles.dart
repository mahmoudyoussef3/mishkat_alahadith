import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

/// HadithTextStyles centralizes text styles used across Hadith UI.
/// Methods and constants are named to reflect their usage contexts.
class HadithTextStyles {
  HadithTextStyles._();

  /// Header category/title in hadith cards.
  static TextStyle headerCategoryTitle = TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeight.w700,
    color: ColorsManager.primaryText,
    fontFamily: 'Amiri',
  );

  /// Grade label text (color varies by grade).
  static TextStyle gradeLabel(Color gradeColor) => TextStyle(
        color: gradeColor,
        fontWeight: FontWeight.w800,
        fontSize: 16.sp,
        fontFamily: 'Amiri',
      );

  /// Main hadith Arabic text.
  static TextStyle hadithArabic = TextStyle(
    fontFamily: 'Amiri',
    color: ColorsManager.primaryText,
    fontSize: 17.sp,
    height: 1.8,
    fontWeight: FontWeight.w500,
  );

  /// Gradient pill text (default 12sp).
  static TextStyle pillLabel(Color textColor, {double? fontSize}) => TextStyle(
        color: textColor,
        fontWeight: FontWeight.w600,
        fontSize: (fontSize ?? 12.sp),
        fontFamily: 'Amiri',
      );

  /// Empty state title.
  static TextStyle emptyTitle = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w800,
    color: ColorsManager.primaryText,
    fontFamily: 'Amiri',
  );

  /// Empty state subtitle.
  static TextStyle emptySubtitle = TextStyle(
    fontSize: 16.sp,
    color: ColorsManager.secondaryText,
    fontFamily: 'Amiri',
  );
}
