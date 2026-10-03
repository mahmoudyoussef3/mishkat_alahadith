import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class SendSuggestionDecorations {
  static Color get scaffoldBackground => ColorsManager.secondaryBackground;

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

  static const double cardElevation = 10;

  static Color get cardShadowColor => ColorsManager.primaryPurple.withOpacity(0.15);

  static RoundedRectangleBorder cardShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(24.r),
  );

  static BoxDecoration cardContainer() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(24.r),
    );
  }

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

  static Color get iconColor => ColorsManager.primaryPurple;

  static double iconSize(bool isTablet) => isTablet ? 45.sp : 35.sp;

  static double iconContainerSize(bool isTablet) => isTablet ? 90.w : 70.w;

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

  static Color get textFieldFillColor => ColorsManager.lightGray.withOpacity(0.1);

  static OutlineInputBorder textFieldEnabledBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.r),
      borderSide: BorderSide(
        color: ColorsManager.primaryPurple,
        width: 1.5,
      ),
    );
  }

  static OutlineInputBorder textFieldFocusedBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.r),
      borderSide: BorderSide(
        color: ColorsManager.primaryPurple,
        width: 2,
      ),
    );
  }

  static EdgeInsets textFieldPadding = EdgeInsets.symmetric(
    horizontal: 16.w,
    vertical: 14.h,
  );

  static Color get sendButtonBackground => ColorsManager.primaryPurple;

  static Color get sendButtonForeground => Colors.white;

  static Color get sendButtonDisabledBackground => ColorsManager.primaryPurple
      .withOpacity(0.6);

  static RoundedRectangleBorder sendButtonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(14.r),
  );

  static const double sendButtonElevation = 3;

  static Color get sendButtonShadowColor => ColorsManager.primaryPurple.withOpacity(
    0.3,
  );

  static double sendButtonHeight(bool isTablet) => isTablet ? 56.h : 52.h;

  static double sendButtonIconSize(bool isTablet) => isTablet ? 22.sp : 20.sp;

  static double loadingIndicatorSize = 20.w;

  static const double loadingIndicatorStrokeWidth = 2.5;

  static Color get loadingIndicatorColor => Colors.white;

  static Color get successSnackbarBackground => ColorsManager.success;

  static Color get errorSnackbarBackground => ColorsManager.error;

  static const SnackBarBehavior snackbarBehavior = SnackBarBehavior.floating;

  static const Duration iconAnimationDuration = Duration(milliseconds: 600);

  static const Curve iconAnimationCurve = Curves.elasticOut;
}
