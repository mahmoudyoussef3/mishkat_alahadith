import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

/// Splash Screen feature decorations
/// Extracted from splash_screen for consistent styling
class SplashDecorations {
  // ==================== SPLASH SCREEN ====================

  /// Scaffold background color
  static const Color scaffoldBackground = ColorsManager.primaryGreen;

  /// Background gradient decoration
  static BoxDecoration backgroundGradient() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ColorsManager.primaryGreen,
          ColorsManager.primaryGreen.withOpacity(0.9),
          ColorsManager.primaryGreen.withOpacity(0.8),
        ],
        stops: const [0.0, 0.9, 1.5],
      ),
    );
  }

  // ==================== LOGO SECTION ====================

  /// Logo container size
  static double logoContainerSize = 140.w;

  /// Logo container decoration
  static BoxDecoration logoContainer() {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: ColorsManager.white,
      boxShadow: [
        BoxShadow(
          color: ColorsManager.black.withOpacity(0.2),
          blurRadius: 30,
          spreadRadius: 5,
          offset: const Offset(0, 15),
        ),
      ],
    );
  }

  /// Logo padding
  static EdgeInsets logoPadding = EdgeInsets.all(25.w);

  /// Logo asset path
  static const String logoAssetPath = 'assets/images/app_logo.png';

  /// Logo scale animation begin offset
  static const Offset logoScaleBegin = Offset(0.0, 0.0);

  /// Logo scale animation end offset
  static const Offset logoScaleEnd = Offset(1.0, 1.0);

  /// Logo shimmer color
  static Color logoShimmerColor = ColorsManager.white.withOpacity(0.3);

  /// Logo shimmer duration (milliseconds)
  static const int logoShimmerDuration = 2000;

  // ==================== APP NAME SECTION ====================

  /// App description padding
  static EdgeInsets appDescriptionPadding = EdgeInsets.symmetric(
    horizontal: 40.w,
  );

  // ==================== LOADING INDICATOR ====================

  /// Loading dot margin
  static EdgeInsets loadingDotMargin = EdgeInsets.symmetric(horizontal: 6.w);

  /// Loading dot size
  static double loadingDotSize = 8.w;

  /// Loading dot color
  static const Color loadingDotColor = ColorsManager.white;

  /// Loading dot decoration
  static BoxDecoration loadingDotDecoration() {
    return const BoxDecoration(
      shape: BoxShape.circle,
      color: ColorsManager.white,
    );
  }

  /// Loading dot scale begin offset
  static const Offset loadingDotScaleBegin = Offset(0.0, 0.0);

  /// Loading dot scale animation end offset (normal)
  static const Offset loadingDotScaleEnd1 = Offset(1.0, 1.0);

  /// Loading dot scale animation end offset (expanded)
  static const Offset loadingDotScaleEnd2 = Offset(1.3, 1.3);

  /// Loading dot scale duration (milliseconds)
  static const int loadingDotScaleDuration = 800;

  /// Loading dot fade in duration (milliseconds)
  static const int loadingDotFadeInDuration = 600;

  // ==================== ANIMATION DURATIONS ====================

  /// Fade animation duration
  static const Duration fadeAnimationDuration = Duration(milliseconds: 1200);

  /// Scale animation duration
  static const Duration scaleAnimationDuration = Duration(milliseconds: 1000);

  /// Slide animation duration
  static const Duration slideAnimationDuration = Duration(milliseconds: 800);

  /// Scale animation start delay
  static const Duration scaleAnimationDelay = Duration(milliseconds: 300);

  /// Slide animation start delay
  static const Duration slideAnimationDelay = Duration(milliseconds: 600);

  /// App name fade in duration (milliseconds)
  static const int appNameFadeInDuration = 1000;

  /// App name slide Y begin offset
  static const double appNameSlideYBegin = 0.3;

  /// App description fade in delay (milliseconds)
  static const int appDescriptionFadeInDelay = 600;

  /// App description fade in duration (milliseconds)
  static const int appDescriptionFadeInDuration = 1000;

  /// App description slide Y begin offset
  static const double appDescriptionSlideYBegin = 0.3;

  /// Navigation delay to next screen
  static const Duration navigationDelay = Duration(seconds: 3);

  // ==================== SPACING ====================

  /// Spacing after logo
  static double spacingAfterLogo = 22.h;

  /// Spacing after app name
  static double spacingAfterAppName = 60.h;

  /// Spacing after app description
  static double spacingAfterDescription = 12.h;

  /// Bottom spacing
  static double bottomSpacing = 60.h;
}
