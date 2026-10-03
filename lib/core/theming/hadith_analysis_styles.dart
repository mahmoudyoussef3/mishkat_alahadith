import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';
import 'styles.dart';

class HadithAnalysisTextStyles {
  static TextStyle get analyzeButtonLabel => TextStyles.titleMedium.copyWith(
    color: ColorsManager.white,
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle resultTitle({Color? textColor}) =>
      TextStyles.titleMedium.copyWith(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: textColor ?? ColorsManager.purpleText,
      );

  static TextStyle resultBody({Color? textColor}) =>
      TextStyles.bodyMedium.copyWith(
        fontSize: 15.sp,
        height: 1.85,
        color: textColor ?? ColorsManager.primaryText,
      );

  static TextStyle get snackText => TextStyle(
    color: ColorsManager.white,
  );
}
