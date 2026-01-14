import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

/// Serag Chat feature text styles
/// Extracted from serag screens and widgets for consistent styling
class SeragTextStyles {
  // ==================== CHAT SCREEN ====================

  /// Header title style (from BuildHeaderAppBar)
  static const String headerTitle = "سراج";
  static const String headerDescription = "مساعد الحديث";

  // ==================== CHAT MESSAGE BUBBLE ====================

  /// User message text style
  static TextStyle userMessage = TextStyle(
    color: Colors.white,
    fontSize: 15.sp,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );

  /// Assistant message text style
  static TextStyle assistantMessage = TextStyle(
    color: ColorsManager.primaryText,
    fontSize: 15.sp,
    height: 1.4,
    fontWeight: FontWeight.w400,
  );

  /// Snackbar copy message text
  static const TextStyle snackbarCopyMessage = TextStyle();

  // ==================== CHAT INPUT SECTION ====================

  /// Input text field style
  static TextStyle inputFieldText = TextStyle(
    fontSize: 15.sp,
    color: ColorsManager.primaryText,
  );

  /// Input hint text style
  static TextStyle inputHintText = TextStyle(
    color: ColorsManager.secondaryText,
    fontSize: 15.sp,
  );

  /// Send button icon size
  static double sendButtonIconSize = 24.sp;

  /// Error snackbar text (from SeragFailure)
  static const TextStyle errorSnackbarText = TextStyle();

  /// Limit exceeded snackbar text
  static TextStyle limitExceededSnackbar = TextStyle(
    color: ColorsManager.secondaryBackground,
    fontSize: 14.sp,
    height: 1.4,
  );

  /// Warning disclaimer text
  static TextStyle warningDisclaimer = TextStyle(
    fontSize: 11.sp,
    color: ColorsManager.secondaryText,
    fontStyle: FontStyle.italic,
  );

  // ==================== EMPTY CHAT STATE ====================

  /// Empty state main text
  static TextStyle emptyStateMainText = TextStyle(
    fontSize: 16.sp,
    color: ColorsManager.secondaryText,
    fontWeight: FontWeight.w500,
  );

  /// Empty state subtitle text
  static TextStyle emptyStateSubtitle = TextStyle(
    fontSize: 14.sp,
    color: ColorsManager.secondaryText.withOpacity(0.7),
  );

  // ==================== REMAINING QUESTIONS CARD ====================

  /// Remaining questions text
  static TextStyle remainingQuestionsText = TextStyle(
    color: ColorsManager.primaryPurple,
    fontWeight: FontWeight.w600,
    fontSize: 14.sp,
  );

  // ==================== NO ATTEMPTS LEFT WIDGET ====================

  /// No attempts warning text
  static const TextStyle noAttemptsWarningText = TextStyle(
    color: Colors.red,
    fontSize: 14,
    height: 1.4,
  );
}
