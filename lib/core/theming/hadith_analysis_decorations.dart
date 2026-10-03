import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

class HadithAnalysisDecorations {
  static BoxDecoration analyzeButton({required bool pressed}) => BoxDecoration(
    color:
        pressed
            ? ColorsManager.primaryGreen.withOpacity(0.85)
            : ColorsManager.primaryGreen,
    borderRadius: BorderRadius.circular(16.r),
  );

  static BoxDecoration resultCard({Color? background}) => BoxDecoration(
    borderRadius: BorderRadius.circular(16.r),
    color: background ?? ColorsManager.primarySoft,
  );

  static BoxDecoration shimmerContainer() => BoxDecoration(
    borderRadius: BorderRadius.circular(12.r),
    color: ColorsManager.cardBackground,
  );

  static BoxDecoration shimmerIconSquare() => BoxDecoration(
    color: ColorsManager.mediumGray,
    borderRadius: BorderRadius.circular(6.r),
  );

  static BoxDecoration shimmerLine() =>
      BoxDecoration(color: ColorsManager.mediumGray);
}
