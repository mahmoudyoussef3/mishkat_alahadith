import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

class QiblahFinderTextStyles {
  static TextStyle get compassCardTitle => TextStyles.titleLarge.copyWith(
    fontWeight: FontWeight.w700,
  );

  static TextStyle get loadingMessage => TextStyles.bodyMedium.copyWith(
    color: ColorsManager.secondaryText,
  );

  static TextStyle get tipsSectionTitle => TextStyles.titleSmall.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get tipText => TextStyles.bodyMedium.copyWith(
    color: ColorsManager.secondaryText,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  static TextStyle get infoChipLabel => TextStyles.bodySmall.copyWith(
    color: ColorsManager.secondaryText,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  static TextStyle get infoChipValue => TextStyles.titleMedium.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.w900,
  );

  static TextStyle get qiblahBadgeText => TextStyles.bodyMedium.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get qiblahDegreeBadge => TextStyles.bodySmall.copyWith(
    color: ColorsManager.purpleText,
    fontWeight: FontWeight.w900,
  );

  static TextStyle get offsetLabel => TextStyles.bodySmall.copyWith(
    color: ColorsManager.secondaryText,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get messageCardTitle => TextStyles.titleLarge.copyWith(
    fontWeight: FontWeight.w800,
  );

  static TextStyle get messageCardDescription => TextStyles.bodyMedium.copyWith(
    color: ColorsManager.secondaryText,
  );

  static TextStyle get messageCardButtonText => TextStyles.labelLarge.copyWith(
    color: ColorsManager.white,
    fontWeight: FontWeight.w700,
  );
}
