import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart' as BaseStyles;

class HomeTextStyles {
  static TextStyle get fabLibraryLabel => TextStyle(
    fontSize: 16.sp,
    color: ColorsManager.white,
  );

  static TextStyle get dailyHadithHeaderLabel => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.white,
  );

  static TextStyle get dailyHadithText => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: ColorsManager.white,
  );

  static TextStyle get readButtonLabel => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.white,
  );

  static TextStyle get categoryName => BaseStyles.TextStyles.titleMedium.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get categoryCountNumber => BaseStyles.TextStyles.titleMedium
      .copyWith(
        color: ColorsManager.white,
        fontWeight: FontWeight.bold,
        fontSize: 18.sp,
      );

  static TextStyle get categoryCountLabel => BaseStyles.TextStyles.bodySmall
      .copyWith(color: ColorsManager.white.withOpacity(0.9), fontSize: 10.sp);

  static TextStyle get mainCategoryTitle => BaseStyles.TextStyles.headlineSmall
      .copyWith(
        color: ColorsManager.white,
        fontWeight: FontWeight.bold,
        fontSize: 18.sp,
      );

  static TextStyle get mainCategoryDescription => BaseStyles.TextStyles.bodySmall
      .copyWith(fontSize: 18.sp, color: ColorsManager.white.withOpacity(0.85));

  static TextStyle get featuredHadithText => BaseStyles.TextStyles.hadithText
      .copyWith(fontSize: 14.sp, height: 1.5);

  static TextStyle get featuredNarrator => BaseStyles.TextStyles.labelMedium
      .copyWith(color: ColorsManager.primaryText, fontWeight: FontWeight.w500);

  static TextStyle get quickActionsTitle => BaseStyles.TextStyles.headlineMedium
      .copyWith(color: ColorsManager.primaryText, fontWeight: FontWeight.bold);

  static TextStyle get quickActionsSubtitle => BaseStyles.TextStyles.bodySmall
      .copyWith(color: ColorsManager.secondaryText, fontSize: 10);

  static TextStyle get searchHint => BaseStyles.TextStyles.bodyMedium.copyWith(
    color: ColorsManager.secondaryText,
  );

  static TextStyle get sectionHeader => BaseStyles.TextStyles.headlineMedium
      .copyWith(color: ColorsManager.primaryText, fontWeight: FontWeight.bold);

  static TextStyle get statsValue => BaseStyles.TextStyles.headlineMedium.copyWith(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get statsTitle => BaseStyles.TextStyles.bodySmall.copyWith(
    color: Colors.white.withOpacity(0.9),
  );
}
