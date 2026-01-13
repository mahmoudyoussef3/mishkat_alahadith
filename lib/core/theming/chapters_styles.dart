import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';
import 'styles.dart';

class ChaptersTextStyles {
  // Number inside chip
  static TextStyle numberLabel = const TextStyle(
    color: ColorsManager.secondaryBackground,
    fontWeight: FontWeight.w800,
  );

  // Chapter title (Arabic)
  static TextStyle chapterTitle = TextStyle(
    color: ColorsManager.black,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.1,
  );

  // Statistics title/value
  static TextStyle statsTitle = TextStyles.titleMedium.copyWith(
    color: ColorsManager.white.withOpacity(0.9),
    fontWeight: FontWeight.w600,
  );

  static TextStyle statsValue = TextStyles.headlineLarge.copyWith(
    color: ColorsManager.white,
    fontWeight: FontWeight.w700,
  );

  // Empty state title and subtitle
  static const TextStyle emptyTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryNavy,
  );

  static TextStyle emptySubtitle = TextStyle(
    fontSize: 14,
    color: Colors.grey.shade600,
  );
}
