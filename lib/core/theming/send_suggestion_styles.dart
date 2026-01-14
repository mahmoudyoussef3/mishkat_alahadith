import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

/// Send Suggestion feature text styles
/// Extracted from send_suggestion_screen for consistent styling
class SendSuggestionTextStyles {
  // ==================== FORM SCREEN ====================

  /// Main title text style
  static TextStyle title(bool isTablet) {
    return TextStyle(
      fontSize: isTablet ? 26.sp : 22.sp,
      fontWeight: FontWeight.bold,
      color: ColorsManager.primaryPurple,
      height: 1.3,
    );
  }

  /// Subtitle text style (emoji subtitle)
  static TextStyle subtitle(bool isTablet) {
    return TextStyle(
      fontSize: isTablet ? 20.sp : 18.sp,
      fontWeight: FontWeight.w600,
      color: ColorsManager.primaryPurple.withOpacity(0.7),
      height: 1.3,
    );
  }

  /// Description text style
  static TextStyle description(bool isTablet) {
    return TextStyle(
      fontSize: isTablet ? 15.sp : 14.sp,
      color: ColorsManager.gray,
      height: 1.5,
    );
  }

  /// TextField hint text style
  static TextStyle textFieldHint(bool isTablet) {
    return TextStyle(color: Colors.grey, fontSize: isTablet ? 15.sp : 14.sp);
  }

  /// TextField input text style
  static TextStyle textFieldInput(bool isTablet) {
    return TextStyle(fontSize: isTablet ? 16.sp : 15.sp, height: 1.6);
  }

  /// TextField counter text style
  static TextStyle textFieldCounter = TextStyle(
    fontSize: 12.sp,
    color: ColorsManager.gray,
  );

  /// Privacy note text style
  static TextStyle privacyNote(bool isTablet) {
    return TextStyle(
      fontSize: isTablet ? 12.sp : 11.sp,
      color: ColorsManager.gray.withOpacity(0.8),
      fontWeight: FontWeight.w500,
    );
  }

  /// Send button text style (normal)
  static TextStyle sendButtonText(bool isTablet) {
    return TextStyle(
      fontSize: isTablet ? 17.sp : 16.sp,
      fontWeight: FontWeight.bold,
    );
  }

  /// Send button loading text style
  static TextStyle sendButtonLoadingText(bool isTablet) {
    return TextStyle(
      fontSize: isTablet ? 17.sp : 16.sp,
      fontWeight: FontWeight.bold,
    );
  }

  /// Footer note text style
  static TextStyle footerNote = TextStyle(
    fontSize: 12.sp,
    color: ColorsManager.gray.withOpacity(0.7),
  );

  /// Snackbar empty message text
  static const TextStyle snackbarEmpty = TextStyle();

  /// Snackbar success message text
  static const TextStyle snackbarSuccess = TextStyle();

  /// Snackbar error message text
  static const TextStyle snackbarError = TextStyle();
}
