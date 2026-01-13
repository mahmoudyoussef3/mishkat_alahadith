import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class DailyHadithTextStyles {
  // Snackbar generic text
  static const TextStyle snackText = TextStyle(
    color: ColorsManager.secondaryBackground,
  );

  // Hadith rich text style (main content)
  static TextStyle hadithText = TextStyle(
    fontSize: 20.sp,
    fontFamily: 'Amiri',
    height: 1.8,
    color: Colors.black87,
    fontWeight: FontWeight.w400,
  );

  // Label chip text (e.g., "نص الحديث")
  static TextStyle labelChip = TextStyle(
    color: ColorsManager.primaryPurple,
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );

  // Tabs label text
  static TextStyle tabLabel({required bool isSelected}) {
    return TextStyle(
      fontSize: isSelected ? 15.sp : 14.sp,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      color: isSelected ? Colors.white : ColorsManager.primaryPurple,
    );
  }

  // Title below icon for hadith title
  static const TextStyle hadithTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryPurple,
  );

  // Actions row label text
  static TextStyle actionLabel = TextStyle(
    fontSize: 13.sp,
    color: ColorsManager.darkGray,
  );

  // Attribution text style (source)
  static const TextStyle attribution = TextStyle(
    fontSize: 16,
    color: ColorsManager.accentPurple,
    fontStyle: FontStyle.italic,
  );

  // Grade chip label style
  static TextStyle gradeLabel(Color color) {
    return TextStyle(color: color, fontWeight: FontWeight.bold);
  }

  // Tab content text styles
  static const TextStyle explanation = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w500,
    color: ColorsManager.black,
    height: 1.6,
  );

  static const TextStyle hintNumber = TextStyle(
    fontWeight: FontWeight.bold,
    color: ColorsManager.black,
  );

  static const TextStyle hintText = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w500,
    color: ColorsManager.black,
  );

  static const TextStyle wordStyle = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w700,
    color: ColorsManager.darkPurple,
  );

  static const TextStyle colonStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: ColorsManager.darkPurple,
  );

  static const TextStyle meaningStyle = TextStyle(
    fontSize: 15,
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  // FAB label (Ask Serag) style
  static TextStyle fabLabel = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.secondaryBackground,
  );
}
