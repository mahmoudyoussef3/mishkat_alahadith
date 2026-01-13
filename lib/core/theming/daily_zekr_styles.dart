import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';
import 'styles.dart';

class DailyZekrTextStyles {
  // Section header title: "اختر ما أنجزته اليوم"
  static TextStyle sectionHeaderTitle = TextStyles.headlineMedium.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.bold,
  );

  // Info card title and body
  static TextStyle infoTitle = TextStyles.titleLarge.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.w700,
  );

  static TextStyle infoBody = TextStyles.bodyMedium.copyWith(
    color: ColorsManager.secondaryText,
  );

  // Hint text under zekr list
  static TextStyle hintText = TextStyles.bodySmall.copyWith(
    color: ColorsManager.gray,
    fontStyle: FontStyle.normal,
  );

  // Zekr card title/description
  static TextStyle zekrTitle({required bool checked}) => TextStyles.titleLarge
      .copyWith(
        color: checked ? ColorsManager.primaryPurple : ColorsManager.primaryText,
        fontFamily: 'Cairo',
      );

  static TextStyle zekrDescription = TextStyles.bodyMedium.copyWith(
    color: ColorsManager.secondaryText,
    fontFamily: 'Cairo',
  );

  // Footer pill label
  static TextStyle footerLabel({required bool enabled, required bool checked}) =>
      TextStyles.labelMedium.copyWith(
        color: !enabled
            ? ColorsManager.secondaryText
            : checked
                ? ColorsManager.hadithAuthentic
                : ColorsManager.primaryGold,
        fontFamily: 'Cairo',
      );

  // Personal tasks title and item text
  static TextStyle personalTasksTitle = TextStyles.titleLarge.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.bold,
  );

  static TextStyle personalTaskText({required bool isDone}) => TextStyles.bodyLarge
      .copyWith(
        color: ColorsManager.primaryText,
        decoration: isDone ? TextDecoration.lineThrough : null,
      );

  // Buttons
  static TextStyle primaryButtonLabel = TextStyles.titleMedium.copyWith(
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static TextStyle sheetTitle = TextStyles.titleLarge.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.bold,
  );

  static TextStyle inputHint = TextStyles.bodyMedium.copyWith(
    color: ColorsManager.secondaryText,
  );
}
