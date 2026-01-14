import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Onboarding feature text styles
/// Extracted from onboarding_screen for consistent styling
class OnboardingTextStyles {
  // ==================== HEADER ====================

  /// App name text style in header
  static TextStyle appNameStyle(Color color) {
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.bold,
      color: color,
    );
  }

  /// Skip button text style
  static TextStyle skipButtonStyle = TextStyle(
    color: Colors.grey.shade600,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
  );

  // ==================== PAGE CONTENT ====================

  /// Page title text style
  static TextStyle pageTitleStyle(bool isSmallScreen) {
    return TextStyle(
      fontSize: isSmallScreen ? 20.sp : 24.sp,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF2D3748),
      height: 1.3,
    );
  }

  /// Page subtitle text style
  static TextStyle pageSubtitleStyle(bool isSmallScreen) {
    return TextStyle(
      fontSize: isSmallScreen ? 14.sp : 16.sp,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
  }

  /// Page description text style
  static TextStyle pageDescriptionStyle(bool isSmallScreen) {
    return TextStyle(
      fontSize: isSmallScreen ? 13.sp : 15.sp,
      color: const Color(0xFF718096),
      height: 1.5,
      fontWeight: FontWeight.w400,
    );
  }

  // ==================== NAVIGATION ====================

  /// Back button text style
  static TextStyle backButtonStyle = TextStyle(
    color: Colors.grey.shade600,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
  );

  /// Next/Start button text style
  static TextStyle nextButtonStyle = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
  );
}
