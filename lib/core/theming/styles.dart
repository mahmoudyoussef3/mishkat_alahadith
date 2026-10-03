import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';
import 'font_weight_helper.dart';

class TextStyles {
  static TextStyle get displayLarge => TextStyle(
    fontSize: 32.sp,
    fontWeight: FontWeightHelper.bold,
    color: ColorsManager.primaryText,
  );

  static TextStyle get displayMedium => TextStyle(
    fontSize: 28.sp,
    fontWeight: FontWeightHelper.bold,
    color: ColorsManager.primaryText,
  );

  static TextStyle get displaySmall => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeightHelper.bold,
    color: ColorsManager.primaryText,
  );

  static TextStyle get headlineLarge => TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeightHelper.bold,
    color: ColorsManager.primaryText,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: ColorsManager.primaryText,
  );

  static TextStyle get headlineSmall => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: ColorsManager.primaryText,
  );

  static TextStyle get titleLarge => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: ColorsManager.primaryText,
  );

  static TextStyle get titleMedium => TextStyle(
    fontSize: 15.sp,
    fontWeight: FontWeightHelper.medium,
    color: ColorsManager.primaryText,
  );

  static TextStyle get titleSmall => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.medium,
    color: ColorsManager.primaryText,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeightHelper.regular,
    color: ColorsManager.primaryText,
    height: 1.5,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.regular,
    color: ColorsManager.primaryText,
    height: 1.4,
  );

  static TextStyle get bodySmall => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.regular,
    color: ColorsManager.secondaryText,
    height: 1.3,
  );

  static TextStyle get labelLarge => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.medium,
    color: ColorsManager.primaryText,
  );

  static TextStyle get labelMedium => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.medium,
    color: ColorsManager.primaryText,
  );

  static TextStyle get labelSmall => TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeightHelper.medium,
    color: ColorsManager.secondaryText,
  );

  static TextStyle get arabicTitle => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeightHelper.bold,
    color: ColorsManager.purpleText,
  );

  /// Long-form reading text (hadith bodies): Amiri with generous line
  /// spacing so diacritics on neighbouring lines never collide.
  static TextStyle get readingLarge => TextStyle(
    fontFamily: 'Amiri',
    fontSize: 21.sp,
    height: 2.0,
    color: ColorsManager.primaryText,
  );

  /// Reading text for previews and cards.
  static TextStyle get readingMedium => TextStyle(
    fontFamily: 'Amiri',
    fontSize: 18.sp,
    height: 1.9,
    color: ColorsManager.primaryText,
  );

  static TextStyle get hadithText => readingMedium;

  /// Body copy for explanations, lessons and word meanings: regular weight
  /// and roomy lines, since these passages are read end to end.
  static TextStyle get explanationBody => TextStyle(
    fontFamily: 'Cairo',
    fontSize: 15.sp,
    fontWeight: FontWeightHelper.regular,
    height: 1.85,
    color: ColorsManager.primaryText,
  );

  /// Source line under a hadith ("رواه البخاري").
  static TextStyle get attribution => TextStyle(
    fontFamily: 'Cairo',
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: ColorsManager.purpleText,
  );

  static TextStyle get quranText => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeightHelper.medium,
    color: ColorsManager.darkPurpleText,
    height: 1.7,
  );

  static TextStyle get authorName => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: ColorsManager.primaryGold,
  );

  static TextStyle get categoryLabel => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeightHelper.medium,
    color: ColorsManager.secondaryPurple,
  );

  static TextStyle get buttonText => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.semiBold,
    color: ColorsManager.white,
  );

  static TextStyle get linkText => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeightHelper.medium,
    color: ColorsManager.purpleText,
    decoration: TextDecoration.underline,
  );

  static TextStyle get font24BlackBold => displaySmall.copyWith(
    color: ColorsManager.primaryText,
  );

  static TextStyle get font32BlueBold => displayLarge.copyWith(
    color: ColorsManager.darkPurpleText,
  );

  static TextStyle get font13BlueSemiBold => labelLarge.copyWith(
    color: ColorsManager.darkPurpleText,
  );

  static TextStyle get font13DarkBlueMedium => bodyMedium.copyWith(
    color: ColorsManager.darkPurpleText,
  );

  static TextStyle get font13DarkBlueRegular => bodyMedium.copyWith(
    color: ColorsManager.darkPurpleText,
  );

  static TextStyle get font24BlueBold => displaySmall.copyWith(
    color: ColorsManager.darkPurpleText,
  );

  static TextStyle get font16WhiteSemiBold => bodyLarge.copyWith(
    color: ColorsManager.white,
    fontWeight: FontWeightHelper.semiBold,
  );

  static TextStyle get font13GrayRegular => bodyMedium.copyWith(
    color: ColorsManager.gray,
  );

  static TextStyle get font12GrayRegular => bodySmall.copyWith(
    color: ColorsManager.gray,
  );

  static TextStyle get font12GrayMedium => bodySmall.copyWith(
    fontWeight: FontWeightHelper.medium,
  );

  static TextStyle get font12DarkBlueRegular => bodySmall.copyWith(
    color: ColorsManager.darkPurpleText,
  );

  static TextStyle get font12BlueRegular => bodySmall.copyWith(
    color: ColorsManager.darkPurpleText,
  );

  static TextStyle get font13BlueRegular => bodyMedium.copyWith(
    color: ColorsManager.darkPurpleText,
  );

  static TextStyle get font14GrayRegular => bodyMedium.copyWith(
    color: ColorsManager.gray,
  );

  static TextStyle get font14LightGrayRegular => bodyMedium.copyWith(
    color: ColorsManager.lightGray,
  );

  static TextStyle get font14DarkBlueMedium => bodyMedium.copyWith(
    color: ColorsManager.darkPurpleText,
    fontWeight: FontWeightHelper.medium,
  );

  static TextStyle get font14DarkBlueBold => bodyMedium.copyWith(
    color: ColorsManager.darkPurpleText,
    fontWeight: FontWeightHelper.bold,
  );

  static TextStyle get font16WhiteMedium => bodyLarge.copyWith(
    color: ColorsManager.white,
    fontWeight: FontWeightHelper.medium,
  );

  static TextStyle get font14BlueSemiBold => bodyMedium.copyWith(
    color: ColorsManager.darkPurpleText,
    fontWeight: FontWeightHelper.semiBold,
  );

  static TextStyle get font15DarkBlueMedium => bodyMedium.copyWith(
    fontSize: 15.sp,
    color: ColorsManager.darkPurpleText,
    fontWeight: FontWeightHelper.medium,
  );

  static TextStyle get font18DarkBlueBold => headlineSmall.copyWith(
    color: ColorsManager.darkPurpleText,
  );

  static TextStyle get font18DarkBlueSemiBold => headlineSmall.copyWith(
    fontWeight: FontWeightHelper.semiBold,
  );

  static TextStyle get font18WhiteMedium => headlineSmall.copyWith(
    color: ColorsManager.white,
    fontWeight: FontWeightHelper.medium,
  );
}
