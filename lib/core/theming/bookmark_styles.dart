import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

/// BookmarkTextStyles centralizes text styles for the Bookmark feature.
class BookmarkTextStyles {
  BookmarkTextStyles._();

  /// Tab label text depending on active state.
  static TextStyle tabLabel({required bool isActive}) => TextStyle(
    color: isActive ? ColorsManager.white : ColorsManager.darkGray,
    fontWeight: FontWeight.bold,
    fontSize: 14.sp,
  );

  /// Search field hint.
  static TextStyle searchHint = TextStyle(
    color: ColorsManager.secondaryText,
    fontSize: 14.sp,
  );

  /// Empty state description.
  static TextStyle emptyStateText = TextStyle(
    color: ColorsManager.secondaryText,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );

  /// Header label in hadith card row.
  static TextStyle headerLabel = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: ColorsManager.primaryText,
  );

  /// Delete action label.
  static TextStyle deleteAction = TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: ColorsManager.error,
  );

  /// Notes text style.
  static TextStyle notesText = TextStyle(
    fontSize: 13.sp,
    color: ColorsManager.secondaryText,
    fontStyle: FontStyle.italic,
  );

  /// Pill label style.
  static TextStyle pillLabel(Color textColor, {double? size}) => TextStyle(
    color: textColor,
    fontWeight: FontWeight.w600,
    fontSize: (size ?? 13.sp),
  );

  /// Collection chip label.
  static TextStyle collectionChipText({required bool isSelected}) => TextStyle(
    color: isSelected ? ColorsManager.white : ColorsManager.primaryText,
    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
    fontSize: 12.sp,
  );

  /// Small section description text (e.g., dialog info).
  static TextStyle sectionDescription = const TextStyle(
    color: ColorsManager.secondaryText,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  /// Create new label.
  static TextStyle createNewLabel = const TextStyle(
    color: ColorsManager.primaryPurple,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  /// Dialog header title.
  static TextStyle dialogTitle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
    color: ColorsManager.primaryText,
  );

  /// Input label.
  static TextStyle inputLabel = const TextStyle(
    color: ColorsManager.secondaryText,
    fontWeight: FontWeight.w500,
  );

  /// Primary button label (non-const).
  static TextStyle primaryButtonLabel = const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: ColorsManager.white,
  );
}
