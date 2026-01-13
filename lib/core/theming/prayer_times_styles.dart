import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart' as BaseStyles;

class PrayerTimesTextStyles {
  // Section header (e.g., "مواقيت اليوم")
  static TextStyle sectionHeaderLabel = BaseStyles.TextStyles.headlineMedium
      .copyWith(color: ColorsManager.primaryText, fontWeight: FontWeight.bold);

  // Next prayer small label ("الصلاة القادمة")
  static TextStyle nextPrayerSectionLabel = BaseStyles.TextStyles.bodyMedium
      .copyWith(
        color: ColorsManager.secondaryText,
        fontWeight: FontWeight.w600,
      );

  // Next prayer name (e.g., "العصر")
  static TextStyle nextPrayerNameLabel = BaseStyles.TextStyles.headlineSmall
      .copyWith(color: ColorsManager.primaryText, fontWeight: FontWeight.bold);

  // Next prayer time value (HH:MM)
  static TextStyle nextPrayerTimeValue = BaseStyles.TextStyles.titleLarge
      .copyWith(
        color: ColorsManager.primaryPurple,
        fontWeight: FontWeight.w700,
      );

  // Countdown value HH:MM:SS
  static TextStyle countdownValue = BaseStyles.TextStyles.titleMedium.copyWith(
    color: ColorsManager.primaryPurple,
    fontWeight: FontWeight.w700,
  );

  // Prayer row title (e.g., "الفجر")
  static TextStyle prayerRowTitle = BaseStyles.TextStyles.titleLarge.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.w700,
  );

  // Prayer row time string
  static TextStyle prayerRowTime = BaseStyles.TextStyles.bodyMedium.copyWith(
    color: ColorsManager.secondaryText,
  );
}
