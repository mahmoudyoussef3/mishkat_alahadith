import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';
import 'styles.dart';

class HadithAnalysisTextStyles {
  // Analyze button label
  static TextStyle analyzeButtonLabel = TextStyles.titleMedium.copyWith(
    color: ColorsManager.secondaryBackground,
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
  );

  // Result title and body
  static TextStyle resultTitle({Color? textColor}) => TextStyles.titleMedium
      .copyWith(fontSize: 18.sp, fontWeight: FontWeight.w600, color: textColor ?? ColorsManager.primaryGreen);

  static TextStyle resultBody({Color? textColor}) => TextStyles.bodyMedium
      .copyWith(fontSize: 16.sp, height: 1.5, color: textColor ?? Colors.black87);

  // Snack bar text
  static const TextStyle snackText = TextStyle(
    color: ColorsManager.secondaryBackground,
  );
}
