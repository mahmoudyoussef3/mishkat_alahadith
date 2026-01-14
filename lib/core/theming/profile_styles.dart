import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

/// Profile feature text styles
/// Extracted from profile screens and widgets for consistent styling
class ProfileTextStyles {
  // ==================== EDIT PROFILE SCREEN ====================

  /// Edit profile screen title
  static TextStyle editProfileTitle = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    fontFamily: 'YaModernPro',
    color: Colors.white,
  );

  /// Save button text
  static TextStyle saveButtonText = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontFamily: 'YaModernPro',
  );

  /// Avatar picker option text
  static TextStyle avatarPickerOption = TextStyle(
    fontSize: 14.sp,
    fontFamily: 'YaModernPro',
  );

  /// Username field hint text
  static TextStyle usernameFieldHint = TextStyle(fontSize: 15.sp);

  /// Username field text
  static TextStyle usernameFieldText = TextStyle(fontSize: 15.sp);

  /// Info card title and value
  static TextStyle infoCardText = TextStyle(
    fontSize: 14.sp,
    fontFamily: 'YaModernPro',
  );

  // ==================== PROFILE HEADER ====================

  /// Profile username in header
  static const TextStyle profileHeaderUsername = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: ColorsManager.white,
  );

  /// Profile email in header
  static TextStyle profileHeaderEmail = TextStyle(
    fontSize: 15,
    color: ColorsManager.white.withOpacity(0.85),
  );

  // ==================== LOGIN PROMPT SECTION ====================

  /// Login prompt title
  static TextStyle loginPromptTitle = TextStyle(
    fontSize: 24.sp,
    color: Colors.black87,
    fontWeight: FontWeight.bold,
  );

  /// Login prompt subtitle
  static TextStyle loginPromptSubtitle = TextStyle(
    fontSize: 16.sp,
    color: ColorsManager.darkGray,
    height: 1.5,
  );

  /// Login button text
  static TextStyle loginButtonText = TextStyle(
    color: Colors.white,
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
  );

  // ==================== NOTIFICATION TOGGLE CARD ====================

  /// Notification card title
  static TextStyle notificationCardTitle = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  /// Notification card subtitle
  static TextStyle notificationCardSubtitle = TextStyle(
    fontSize: 13.sp,
    color: Colors.grey.shade600,
    height: 1.3,
  );

  // ==================== NOTIFICATION SYSTEM ====================

  /// Section header text
  static TextStyle sectionHeaderText = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  // ==================== LAST ACTIVITY CARD ====================

  /// Last activity label
  static TextStyle lastActivityLabel = TextStyle(
    fontSize: 14.sp,
    color: Colors.white.withOpacity(0.9),
    fontWeight: FontWeight.w600,
  );

  /// Last activity date
  static TextStyle lastActivityDate = TextStyle(
    fontSize: 18.sp,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  // ==================== DARK MODE TOGGLE ====================

  /// Dark mode title
  static TextStyle darkModeTitle = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );

  /// Dark mode status
  static TextStyle darkModeStatus = TextStyle(
    fontSize: 14.sp,
    color: ColorsManager.secondaryText,
  );

  // ==================== STATS CARD ====================

  /// Stat value (large number)
  static TextStyle statValue = TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );

  /// Stat title/label
  static TextStyle statTitle = TextStyle(
    fontSize: 13.sp,
    color: Colors.grey.shade600,
    fontWeight: FontWeight.w500,
  );

  // ==================== STATISTICS SECTION ====================

  /// Error message text
  static TextStyle statsErrorMessage = TextStyle(
    fontSize: 14.sp,
    color: Colors.red,
  );

  // ==================== SECTION TITLE ====================

  /// Section title text
  static TextStyle sectionTitleText = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: ColorsManager.primaryText,
  );

  // ==================== SOCIAL MEDIA ICONS ====================

  /// App name in social media screen
  static TextStyle socialMediaAppName = TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: Colors.purple,
  );

  /// App tagline
  static TextStyle socialMediaTagline = TextStyle(
    fontSize: 14.sp,
    color: Colors.grey.shade700,
  );

  /// Card title in social media
  static TextStyle socialMediaCardTitle = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
  );

  /// Card description
  static TextStyle socialMediaCardDescription = TextStyle(
    fontSize: 13.sp,
    color: Colors.grey.shade700,
    height: 1.4,
  );

  /// Terms and privacy links
  static TextStyle socialMediaLinks = TextStyle(
    color: Colors.purple,
    fontSize: 13.sp,
  );

  /// Copyright text
  static TextStyle copyrightText = TextStyle(
    fontSize: 11.sp,
    color: Colors.grey.shade600,
  );

  // ==================== SUCCESS SNACKBAR ====================

  /// Success snackbar text
  static TextStyle successSnackbarText = TextStyle(
    color: ColorsManager.secondaryBackground,
  );
}
