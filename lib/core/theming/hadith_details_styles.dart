import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class HadithDetailsTextStyles {
  // Generic snackbar text
  static const TextStyle snackText = TextStyle(
    color: ColorsManager.secondaryBackground,
  );

  // Chip label text ("نص الحديث")
  static TextStyle labelChip = TextStyle(
    color: ColorsManager.primaryPurple,
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );

  // Hadith main text style
  static TextStyle hadithText = TextStyle(
    fontSize: 20.sp,
    height: 1.8,
    color: ColorsManager.primaryText,
    fontFamily: 'Amiri',
    fontWeight: FontWeight.w500,
  );

  // Book section label and value
  static TextStyle bookLabel = TextStyle(
    fontSize: 14.sp,
    color: ColorsManager.darkGray,
    fontWeight: FontWeight.w600,
  );

  static TextStyle bookValue = TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryText,
  );

  // Grade chip label style
  static TextStyle gradeLabel(Color color) {
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  // Navigation row label (both loading and id)
  static TextStyle navigationLabel = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryPurple,
  );

  // Header info main and sub lines
  static TextStyle headerMain = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: ColorsManager.primaryText,
  );

  static TextStyle headerSub = TextStyle(
    fontSize: 13.sp,
    color: ColorsManager.secondaryText,
  );

  // FAB label
  static TextStyle fabLabel = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.secondaryBackground,
  );

  // Action row label text
  static TextStyle actionLabel = TextStyle(
    fontSize: 13.sp,
    color: ColorsManager.darkGray,
  );
}
