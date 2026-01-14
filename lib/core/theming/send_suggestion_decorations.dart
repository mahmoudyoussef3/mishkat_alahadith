import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

/// Send Suggestion feature decorations
/// Extracted from send_suggestion_screen for consistent styling
class SendSuggestionDecorations {
  // ==================== FORM SCREEN ====================

  /// Scaffold background color
  static const Color scaffoldBackground = Colors.white;

  /// Background gradient decoration
  static BoxDecoration backgroundGradient() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          ColorsManager.secondaryBackground,
          ColorsManager.lightGray.withOpacity(0.2),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  /// Main card elevation
  static const double cardElevation = 10;

  /// Main card shadow color
  static Color cardShadowColor = ColorsManager.primaryPurple.withOpacity(0.15);

  /// Main card shape
  static RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24.r),
  );

  /// Card container decoration
  static BoxDecoration cardContainer() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24.r),
    );
  }

  /// Icon container decoration (animated)
  static BoxDecoration iconContainer() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          ColorsManager.primaryPurple.withOpacity(0.15),
          ColorsManager.primaryPurple.withOpacity(0.05),
        ],
      ),
      shape: BoxShape.circle,
    );
  }

  /// Icon color
  static const Color iconColor = ColorsManager.primaryPurple;

  /// Icon size
  static double iconSize(bool isTablet) => isTablet ? 45.sp : 35.sp;

  /// Icon container size
  static double iconContainerSize(bool isTablet) => isTablet ? 90.w : 70.w;

  /// TextField container decoration (shadow wrapper)
  static BoxDecoration textFieldShadowContainer() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: ColorsManager.white.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// TextField fill color
  static Color textFieldFillColor = ColorsManager.lightGray.withOpacity(0.1);

  /// TextField enabled border
  static OutlineInputBorder textFieldEnabledBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.r),
      borderSide: const BorderSide(
        color: ColorsManager.primaryPurple,
        width: 1.5,
      ),
    );
  }

  /// TextField focused border
  static OutlineInputBorder textFieldFocusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.r),
      borderSide: const BorderSide(
        color: ColorsManager.primaryPurple,
        width: 2,
      ),
    );
  }

  /// TextField content padding
  static EdgeInsets textFieldPadding = EdgeInsets.symmetric(
    horizontal: 16.w,
    vertical: 14.h,
  );

  /// Send button background color
  static const Color sendButtonBackground = ColorsManager.primaryPurple;

  /// Send button foreground color
  static const Color sendButtonForeground = Colors.white;

  /// Send button disabled background color
  static Color sendButtonDisabledBackground = ColorsManager.primaryPurple
      .withOpacity(0.6);

  /// Send button shape
  static RoundedRectangleBorder sendButtonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14.r),
  );

  /// Send button elevation
  static const double sendButtonElevation = 3;

  /// Send button shadow color
  static Color sendButtonShadowColor = ColorsManager.primaryPurple.withOpacity(
    0.3,
  );

  /// Send button height
  static double sendButtonHeight(bool isTablet) => isTablet ? 56.h : 52.h;

  /// Send button icon size
  static double sendButtonIconSize(bool isTablet) => isTablet ? 22.sp : 20.sp;

  /// Loading indicator size
  static double loadingIndicatorSize = 20.w;

  /// Loading indicator stroke width
  static const double loadingIndicatorStrokeWidth = 2.5;

  /// Loading indicator color
  static const Color loadingIndicatorColor = Colors.white;

  /// Success snackbar background color
  static const Color successSnackbarBackground = ColorsManager.success;

  /// Error snackbar background color
  static const Color errorSnackbarBackground = ColorsManager.error;

  /// Snackbar behavior
  static const SnackBarBehavior snackbarBehavior = SnackBarBehavior.floating;

  /// Animation duration (icon scale)
  static const Duration iconAnimationDuration = Duration(milliseconds: 600);

  /// Animation curve (icon scale)
  static const Curve iconAnimationCurve = Curves.elasticOut;
}
