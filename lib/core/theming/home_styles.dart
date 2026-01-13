import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart' as BaseStyles;

class HomeTextStyles {
  // FAB label for library
  static TextStyle fabLibraryLabel = TextStyle(
    fontSize: 16.sp,
    color: ColorsManager.secondaryBackground,
  );

  // Daily hadith header label ("حديث اليوم")
  static TextStyle dailyHadithHeaderLabel = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.secondaryBackground,
  );

  // Daily hadith text inside card
  static TextStyle dailyHadithText = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: ColorsManager.secondaryBackground,
  );

  // Read button label
  static TextStyle readButtonLabel = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.secondaryBackground,
  );

  // Category name text
  static TextStyle categoryName = BaseStyles.TextStyles.titleMedium.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.w600,
  );

  // Category count number & label
  static TextStyle categoryCountNumber = BaseStyles.TextStyles.titleMedium.copyWith(
    color: ColorsManager.white,
    fontWeight: FontWeight.bold,
    fontSize: 18.sp,
  );

  static TextStyle categoryCountLabel = BaseStyles.TextStyles.bodySmall.copyWith(
    color: ColorsManager.white.withOpacity(0.9),
    fontSize: 10.sp,
  );

  // Main category title & description
  static TextStyle mainCategoryTitle = BaseStyles.TextStyles.headlineSmall.copyWith(
    color: ColorsManager.white,
    fontWeight: FontWeight.bold,
    fontSize: 18.sp,
  );

  static TextStyle mainCategoryDescription = BaseStyles.TextStyles.bodySmall.copyWith(
    fontSize: 18.sp,
    color: ColorsManager.white.withOpacity(0.85),
  );

  // Featured hadith content text and narrator row
  static TextStyle featuredHadithText = BaseStyles.TextStyles.hadithText.copyWith(
    fontSize: 14.sp,
    height: 1.5,
  );

  static TextStyle featuredNarrator = BaseStyles.TextStyles.labelMedium.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.w500,
  );

  // Quick actions title & subtitle
  static TextStyle quickActionsTitle = BaseStyles.TextStyles.headlineMedium.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.bold,
  );

  static TextStyle quickActionsSubtitle = BaseStyles.TextStyles.bodySmall.copyWith(
    color: ColorsManager.secondaryText,
    fontSize: 10,
  );

  // Search hint style
  static TextStyle searchHint = BaseStyles.TextStyles.bodyMedium.copyWith(
    color: ColorsManager.secondaryText,
  );

  // Section header (e.g., Top Books)
  static TextStyle sectionHeader = BaseStyles.TextStyles.headlineMedium.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.bold,
  );

  // Statistics card values and titles
  static TextStyle statsValue = BaseStyles.TextStyles.headlineMedium.copyWith(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static TextStyle statsTitle = BaseStyles.TextStyles.bodySmall.copyWith(
    color: Colors.white.withOpacity(0.9),
  );
}
