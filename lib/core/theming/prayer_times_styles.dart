import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart' as BaseStyles;

class PrayerTimesTextStyles {
  static TextStyle get sectionHeaderLabel => BaseStyles.TextStyles.headlineMedium
      .copyWith(color: ColorsManager.primaryText, fontWeight: FontWeight.bold);

  static TextStyle get nextPrayerSectionLabel => BaseStyles.TextStyles.bodyMedium
      .copyWith(
        color: ColorsManager.secondaryText,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get nextPrayerNameLabel => BaseStyles.TextStyles.headlineSmall
      .copyWith(color: ColorsManager.primaryText, fontWeight: FontWeight.bold);

  static TextStyle get nextPrayerTimeValue => BaseStyles.TextStyles.titleLarge
      .copyWith(
        color: ColorsManager.primaryPurple,
        fontWeight: FontWeight.w700,
      );

  static TextStyle get countdownValue => BaseStyles.TextStyles.titleMedium.copyWith(
    color: ColorsManager.primaryPurple,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get prayerRowTitle => BaseStyles.TextStyles.titleLarge.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get prayerRowTime => BaseStyles.TextStyles.bodyMedium.copyWith(
    color: ColorsManager.secondaryText,
  );
}
