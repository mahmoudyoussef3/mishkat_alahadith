import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

/// Profile feature decorations
/// Extracted from profile screens and widgets for consistent styling
class ProfileDecorations {
  // ==================== EDIT PROFILE SCREEN ====================

  /// Edit profile screen background gradient
  static BoxDecoration editProfileBackground = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        ColorsManager.primaryPurple.withOpacity(0.85),
        ColorsManager.primaryBackground,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  /// Save button decoration
  static BoxDecoration saveButton() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple,
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  /// Avatar section circle shadow
  static List<BoxShadow> avatarShadow() {
    return [
      BoxShadow(color: Colors.black26, blurRadius: 10.r, spreadRadius: 2.r),
    ];
  }

  /// Avatar picker sheet decoration
  static BoxDecoration avatarPickerSheet() {
    return BoxDecoration(
      color: ColorsManager.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    );
  }

  /// Username text field decoration
  static InputDecoration usernameFieldDecoration() {
    return InputDecoration(
      prefixIcon: Icon(Icons.person, color: ColorsManager.primaryPurple),
      hintText: "أدخل اسم المستخدم",
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
    );
  }

  /// Info card decoration
  static BoxDecoration infoCard() {
    return BoxDecoration(borderRadius: BorderRadius.circular(16.r));
  }

  // ==================== PROFILE HEADER ====================

  /// Profile header gradient
  static BoxDecoration profileHeaderGradient = const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [ColorsManager.primaryPurple, ColorsManager.secondaryPurple],
    ),
  );

  // ==================== LOGIN PROMPT SECTION ====================

  /// Login prompt icon container
  static BoxDecoration loginPromptIconContainer() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withOpacity(0.1),
      shape: BoxShape.circle,
    );
  }

  /// Login button decoration
  static BoxDecoration loginButton() {
    return BoxDecoration(
      color: ColorsManager.primaryGreen,
      borderRadius: BorderRadius.circular(14.r),
    );
  }

  /// Login button shadow
  static List<BoxShadow> loginButtonShadow() {
    return [
      BoxShadow(
        color: ColorsManager.primaryGreen.withOpacity(0.3),
        blurRadius: 2,
        offset: const Offset(0, 0),
      ),
    ];
  }

  // ==================== NOTIFICATION TOGGLE CARD ====================

  /// Notification card container
  static BoxDecoration notificationCard(bool isEnabled) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(
        color:
            isEnabled
                ? ColorsManager.primaryPurple.withOpacity(0.3)
                : Colors.grey.shade200,
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

  /// Notification icon container
  static BoxDecoration notificationIconContainer(bool isEnabled) {
    return BoxDecoration(
      color:
          isEnabled
              ? ColorsManager.primaryPurple.withOpacity(0.15)
              : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  /// Notification switch colors
  static Color notificationSwitchActiveColor = ColorsManager.primaryPurple;
  static Color notificationSwitchActiveTrackColor = ColorsManager.primaryPurple
      .withOpacity(0.5);
  static Color notificationSwitchInactiveThumbColor = Colors.grey.shade400;
  static Color notificationSwitchInactiveTrackColor = Colors.grey.shade300;

  // ==================== LAST ACTIVITY CARD ====================

  /// Last activity card gradient
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

  /// Last activity icon container
  static BoxDecoration lastActivityIconContainer() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.25),
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  // ==================== DARK MODE TOGGLE ====================

  /// Dark mode toggle card
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

  /// Dark mode switch active color
  static Color darkModeSwitchActiveColor = ColorsManager.primaryPurple;

  // ==================== STATS CARD ====================

  /// Stats card container
  static BoxDecoration statsCard(Color color) {
    return BoxDecoration(
      color: Colors.white,
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

  /// Stats icon container
  static BoxDecoration statsIconContainer(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  // ==================== SECTION TITLE ====================

  /// Section title bar decoration
  static BoxDecoration sectionTitleBar() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple,
      borderRadius: BorderRadius.circular(2.r),
    );
  }

  // ==================== PROFILE OPTION TILE ====================

  /// Profile option tile container
  static BoxDecoration profileOptionTile() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: ColorsManager.mediumGray, width: 1),
    );
  }

  // ==================== SOCIAL MEDIA ICONS ====================

  /// Social media screen background color
  static Color socialMediaBackground = Colors.grey.shade50;

  /// Social media icon circle
  static BoxDecoration socialMediaIconCircle(Color color) {
    return BoxDecoration(color: color.withOpacity(0.15));
  }

  /// Social media card
  static BoxDecoration socialMediaCard() {
    return BoxDecoration(borderRadius: BorderRadius.circular(16.r));
  }

  // ==================== SNACKBAR ====================

  /// Success snackbar decoration
  static Color successSnackbarBackground = ColorsManager.hadithAuthentic;
  static SnackBarBehavior successSnackbarBehavior = SnackBarBehavior.floating;

  /// Error snackbar background
  static Color errorSnackbarBackground = Colors.red;
}
