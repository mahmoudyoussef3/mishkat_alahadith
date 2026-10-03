import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class ProfileTextStyles {
  static TextStyle get editProfileTitle => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    fontFamily: 'YaModernPro',
    color: Colors.white,
  );

  static TextStyle get saveButtonText => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'YaModernPro',
  );

  static TextStyle avatarPickerOption = TextStyle(
    fontSize: 14.sp,
    fontFamily: 'YaModernPro',
  );

  static TextStyle usernameFieldHint = TextStyle(fontSize: 15.sp);

  static TextStyle usernameFieldText = TextStyle(fontSize: 15.sp);

  static TextStyle infoCardText = TextStyle(
    fontSize: 14.sp,
    fontFamily: 'YaModernPro',
  );

  static TextStyle get profileHeaderUsername => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: ColorsManager.white,
  );

  static TextStyle get profileHeaderEmail => TextStyle(
    fontSize: 15,
    color: ColorsManager.white.withOpacity(0.85),
  );

  static TextStyle get loginPromptTitle => TextStyle(
    fontSize: 24.sp,
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get loginPromptSubtitle => TextStyle(
    fontSize: 16.sp,
    color: ColorsManager.darkGray,
    height: 1.5,
  );

  static TextStyle get loginButtonText => TextStyle(
    color: Colors.white,
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get notificationCardTitle => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryText,
  );

  static TextStyle get notificationCardSubtitle => TextStyle(
    fontSize: 13.sp,
    color: ColorsManager.secondaryText,
    height: 1.3,
  );

  static TextStyle get sectionHeaderText => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryText,
  );

  static TextStyle get lastActivityLabel => TextStyle(
    fontSize: 14.sp,
    color: Colors.white.withOpacity(0.9),
    fontWeight: FontWeight.w600,
  );

  static TextStyle get lastActivityDate => TextStyle(
    fontSize: 18.sp,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static TextStyle darkModeTitle = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get darkModeStatus => TextStyle(
    fontSize: 14.sp,
    color: ColorsManager.secondaryText,
  );

  static TextStyle get statValue => TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryText,
  );

  static TextStyle get statTitle => TextStyle(
    fontSize: 13.sp,
    color: ColorsManager.secondaryText,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get statsErrorMessage => TextStyle(
    fontSize: 14.sp,
    color: ColorsManager.error,
  );

  static TextStyle get sectionTitleText => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: ColorsManager.primaryText,
  );

  static TextStyle get socialMediaAppName => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.purpleText,
  );

  static TextStyle get socialMediaTagline => TextStyle(
    fontSize: 14.sp,
    color: ColorsManager.darkGray,
  );

  static TextStyle socialMediaCardTitle = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get socialMediaCardDescription => TextStyle(
    fontSize: 13.sp,
    color: ColorsManager.darkGray,
    height: 1.4,
  );

  static TextStyle get socialMediaLinks => TextStyle(
    color: ColorsManager.purpleText,
    fontSize: 13.sp,
  );

  static TextStyle get copyrightText => TextStyle(
    fontSize: 11.sp,
    color: ColorsManager.secondaryText,
  );

  static TextStyle get successSnackbarText => TextStyle(
    color: ColorsManager.white,
  );
}
