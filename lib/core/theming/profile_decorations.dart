import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class ProfileDecorations {
  static BoxDecoration get editProfileBackground => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        ColorsManager.primaryPurple.withOpacity(0.85),
        ColorsManager.primaryBackground,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  static BoxDecoration saveButton() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple,
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  static List<BoxShadow> avatarShadow() {
    return [
      BoxShadow(color: Colors.black26, blurRadius: 10.r, spreadRadius: 2.r),
    ];
  }

  static BoxDecoration avatarPickerSheet() {
    return BoxDecoration(
      color: ColorsManager.elevatedSurface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    );
  }

  static InputDecoration usernameFieldDecoration() {
    return InputDecoration(
      prefixIcon: Icon(Icons.person, color: ColorsManager.primaryPurple),
      hintText: "أدخل اسم المستخدم",
      filled: true,
      fillColor: ColorsManager.cardBackground,
      contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
    );
  }

  static BoxDecoration infoCard() {
    return BoxDecoration(borderRadius: BorderRadius.circular(16.r));
  }

  static BoxDecoration get profileHeaderGradient => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [ColorsManager.primaryPurple, ColorsManager.secondaryPurple],
    ),
  );

  static BoxDecoration loginPromptIconContainer() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withOpacity(0.1),
      shape: BoxShape.circle,
    );
  }

  static BoxDecoration loginButton() {
    return BoxDecoration(
      color: ColorsManager.primaryGreen,
      borderRadius: BorderRadius.circular(14.r),
    );
  }

  static List<BoxShadow> loginButtonShadow() {
    return [
      BoxShadow(
        color: ColorsManager.primaryGreen.withOpacity(0.3),
        blurRadius: 2,
        offset: const Offset(0, 0),
      ),
    ];
  }

  static BoxDecoration notificationCard(bool isEnabled) {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(
        color:
            isEnabled
                ? ColorsManager.primaryPurple.withOpacity(0.3)
                : ColorsManager.mediumGray,
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color:
              isEnabled
                  ? ColorsManager.primaryPurple.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration notificationIconContainer(bool isEnabled) {
    return BoxDecoration(
      color:
          isEnabled
              ? ColorsManager.primaryPurple.withOpacity(0.15)
              : ColorsManager.lightGray,
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  static Color get notificationSwitchActiveColor => ColorsManager.primaryPurple;
  static Color get notificationSwitchActiveTrackColor => ColorsManager.primaryPurple
      .withOpacity(0.5);
  static Color get notificationSwitchInactiveThumbColor => ColorsManager.disabledText;
  static Color get notificationSwitchInactiveTrackColor => ColorsManager.mediumGray;

  static BoxDecoration lastActivityCard() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [ColorsManager.error.withOpacity(0.8), ColorsManager.error],
      ),
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: ColorsManager.error.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration lastActivityIconContainer() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.25),
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  static BoxDecoration darkModeCard() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: ColorsManager.mediumGray, width: 1),
      boxShadow: [
        BoxShadow(
          color: ColorsManager.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static Color get darkModeSwitchActiveColor => ColorsManager.primaryPurple;

  static BoxDecoration statsCard(Color color) {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.15),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration statsIconContainer(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  static BoxDecoration sectionTitleBar() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple,
      borderRadius: BorderRadius.circular(2.r),
    );
  }

  static BoxDecoration profileOptionTile() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: ColorsManager.mediumGray, width: 1),
    );
  }

  static Color get socialMediaBackground => ColorsManager.offWhite;

  static BoxDecoration socialMediaIconCircle(Color color) {
    return BoxDecoration(color: color.withOpacity(0.15));
  }

  static BoxDecoration socialMediaCard() {
    return BoxDecoration(borderRadius: BorderRadius.circular(16.r));
  }

  static Color get successSnackbarBackground => ColorsManager.hadithAuthentic;
  static SnackBarBehavior successSnackbarBehavior = SnackBarBehavior.floating;

  static Color get errorSnackbarBackground => Colors.red;
}
