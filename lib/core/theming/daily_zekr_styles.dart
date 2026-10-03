import 'package:flutter/material.dart';
import 'colors.dart';
import 'styles.dart';

class DailyZekrTextStyles {
  static TextStyle get sectionHeaderTitle => TextStyles.headlineMedium.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get infoTitle => TextStyles.titleLarge.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get infoBody => TextStyles.bodyMedium.copyWith(
    color: ColorsManager.secondaryText,
  );

  static TextStyle get hintText => TextStyles.bodySmall.copyWith(
    color: ColorsManager.gray,
    fontStyle: FontStyle.normal,
  );

  static TextStyle zekrTitle({required bool checked}) =>
      TextStyles.titleLarge.copyWith(
        color:
            checked ? ColorsManager.primaryPurple : ColorsManager.primaryText,
        fontFamily: 'Cairo',
      );

  static TextStyle get zekrDescription => TextStyles.bodyMedium.copyWith(
    color: ColorsManager.secondaryText,
    fontFamily: 'Cairo',
  );

  static TextStyle footerLabel({
    required bool enabled,
    required bool checked,
  }) => TextStyles.labelMedium.copyWith(
    color:
        !enabled
            ? ColorsManager.secondaryText
            : checked
            ? ColorsManager.hadithAuthentic
            : ColorsManager.primaryGold,
    fontFamily: 'Cairo',
  );

  static TextStyle get personalTasksTitle => TextStyles.titleLarge.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.bold,
  );

  static TextStyle personalTaskText({required bool isDone}) =>
      TextStyles.bodyLarge.copyWith(
        color: ColorsManager.primaryText,
        decoration: isDone ? TextDecoration.lineThrough : null,
      );

  static TextStyle get primaryButtonLabel => TextStyles.titleMedium.copyWith(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get sheetTitle => TextStyles.titleLarge.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get inputHint => TextStyles.bodyMedium.copyWith(
    color: ColorsManager.secondaryText,
  );
}
