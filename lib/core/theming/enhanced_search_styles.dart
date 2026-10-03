import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class EnhancedSearchTextStyles {
  static TextStyle get seragFabLabel => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.white,
  );

  static TextStyle get loginRequiredSnackbar => TextStyle(
    color: ColorsManager.white,
  );

  static TextStyle get loginButtonSnackbar => TextStyle(color: Colors.white);

  static TextStyle get hadithTitle => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: ColorsManager.purpleText,
  );

  static TextStyle get specialWord => TextStyles.readingLarge.copyWith(
    color: ColorsManager.purpleText,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get regularWord => TextStyles.readingLarge;

  static TextStyle get wordDialogTitle => TextStyle(
    fontWeight: FontWeight.bold,
    color: ColorsManager.purpleText,
  );

  static TextStyle get attribution => TextStyles.attribution;

  static TextStyle gradeChipText(Color color) {
    return TextStyle(color: color, fontWeight: FontWeight.bold);
  }

  static TextStyle get explanationText => TextStyles.explanationBody;

  static TextStyle get hintsCounter => TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w500,
    color: ColorsManager.primaryText,
  );

  static TextStyle get hintsContent =>
      TextStyles.explanationBody.copyWith(color: ColorsManager.darkGray);

  static TextStyle get wordMeaningWord => TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w700,
    color: ColorsManager.darkPurpleText,
  );

  static TextStyle get wordMeaningSeparator => TextStyle(
    fontWeight: FontWeight.bold,
    color: ColorsManager.darkPurpleText,
  );

  static TextStyle get wordMeaningText => TextStyle(
    fontSize: 15,
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w500,
    color: ColorsManager.primaryText,
  );

  static const TextStyle emptyStateText = TextStyle();

  static TextStyle get selectedTabText => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.purpleText,
  );

  static TextStyle get unselectedTabText => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: ColorsManager.primaryText,
  );

  static TextStyle get hadithContentLabel => TextStyle(
    color: ColorsManager.purpleText,
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get hadithLabelText => TextStyle(
    color: ColorsManager.purpleText,
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle snackbarSuccess = TextStyle();

  static TextStyle get actionButtonLabel => TextStyle(
    fontSize: 13.sp,
    color: ColorsManager.darkGray,
  );

  static TextStyle get snackBarText => TextStyle(
    color: ColorsManager.white,
  );

  static const TextStyle actionSuccessSnackbar = TextStyle();

  static const TextStyle actionErrorSnackbar = TextStyle();
}
