import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart' as BaseStyles;

class LibraryTextStyles {
  // Book title text
  static TextStyle bookTitle = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryText,
  );

  // Book writer/author text
  static TextStyle bookWriter = TextStyle(
    fontSize: 12.sp,
    color: ColorsManager.secondaryText,
  );

  // Stat text (chapters/hadith counts)
  static TextStyle statText = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: ColorsManager.secondaryText,
  );

  // Screen header in Library sections (optional reuse)
  static TextStyle sectionHeader = BaseStyles.TextStyles.headlineMedium.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.bold,
  );
}
