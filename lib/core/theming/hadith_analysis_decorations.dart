import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

class HadithAnalysisDecorations {
  // Analyze button container with press state
  static BoxDecoration analyzeButton({required bool pressed}) => BoxDecoration(
        color: pressed
            ? ColorsManager.primaryGreen.withOpacity(0.85)
            : ColorsManager.primaryGreen,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryGreen.withOpacity(0.4),
            blurRadius: pressed ? 2 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      );

  // Result card background (allows override)
  static BoxDecoration resultCard({Color? background}) => BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: background ?? ColorsManager.primaryGreen.withOpacity(0.05),
      );

  // Shimmer container and parts
  static BoxDecoration shimmerContainer() => BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
      );

  static BoxDecoration shimmerIconSquare() => BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6.r),
      );

  static BoxDecoration shimmerLine() => BoxDecoration(
        color: Colors.grey.shade300,
      );
}
