import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

class BookmarkTextStyles {
  BookmarkTextStyles._();

  static TextStyle tabLabel({required bool isActive}) => TextStyle(
    color: isActive ? ColorsManager.white : ColorsManager.darkGray,
    fontWeight: FontWeight.bold,
    fontSize: 14.sp,
  );

  static TextStyle get searchHint => TextStyle(
    color: ColorsManager.secondaryText,
    fontSize: 14.sp,
  );

  static TextStyle get emptyStateText => TextStyle(
    color: ColorsManager.secondaryText,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get headerLabel => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: ColorsManager.primaryText,
  );

  static TextStyle get deleteAction => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: ColorsManager.error,
  );

  static TextStyle get notesText => TextStyle(
    fontSize: 13.sp,
    color: ColorsManager.secondaryText,
    fontStyle: FontStyle.italic,
  );

  static TextStyle pillLabel(Color textColor, {double? size}) => TextStyle(
    color: textColor,
    fontWeight: FontWeight.w600,
    fontSize: (size ?? 13.sp),
  );

  static TextStyle collectionChipText({required bool isSelected}) => TextStyle(
    color: isSelected ? ColorsManager.white : ColorsManager.primaryText,
    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
    fontSize: 12.sp,
  );

  static TextStyle get sectionDescription => TextStyle(
    color: ColorsManager.secondaryText,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get createNewLabel => TextStyle(
    color: ColorsManager.purpleText,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get dialogTitle => TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
    color: ColorsManager.primaryText,
  );

  static TextStyle get inputLabel => TextStyle(
    color: ColorsManager.secondaryText,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get primaryButtonLabel => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: ColorsManager.white,
  );
}
