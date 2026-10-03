import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class SplashDecorations {
  static Color get scaffoldBackground => ColorsManager.primaryGreen;

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

  static double logoContainerSize = 140.w;

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

  static EdgeInsets logoPadding = EdgeInsets.all(25.w);

  static const String logoAssetPath = 'assets/images/app_logo.png';

  static const Offset logoScaleBegin = Offset(0.0, 0.0);

  static const Offset logoScaleEnd = Offset(1.0, 1.0);

  static Color get logoShimmerColor => ColorsManager.white.withOpacity(0.3);

  static const int logoShimmerDuration = 2000;

  static EdgeInsets appDescriptionPadding = EdgeInsets.symmetric(
    horizontal: 40.w,
  );

  static EdgeInsets loadingDotMargin = EdgeInsets.symmetric(horizontal: 6.w);

  static double loadingDotSize = 8.w;

  static Color get loadingDotColor => ColorsManager.white;

  static BoxDecoration loadingDotDecoration() {
    return const BoxDecoration(
      shape: BoxShape.circle,
      color: ColorsManager.white,
    );
  }

  static const Offset loadingDotScaleBegin = Offset(0.0, 0.0);

  static const Offset loadingDotScaleEnd1 = Offset(1.0, 1.0);

  static const Offset loadingDotScaleEnd2 = Offset(1.3, 1.3);

  static const int loadingDotScaleDuration = 800;

  static const int loadingDotFadeInDuration = 600;

  static const Duration fadeAnimationDuration = Duration(milliseconds: 1200);

  static const Duration scaleAnimationDuration = Duration(milliseconds: 1000);

  static const Duration slideAnimationDuration = Duration(milliseconds: 800);

  static const Duration scaleAnimationDelay = Duration(milliseconds: 300);

  static const Duration slideAnimationDelay = Duration(milliseconds: 600);

  static const int appNameFadeInDuration = 1000;

  static const double appNameSlideYBegin = 0.3;

  static const int appDescriptionFadeInDelay = 600;

  static const int appDescriptionFadeInDuration = 1000;

  static const double appDescriptionSlideYBegin = 0.3;

  static const Duration navigationDelay = Duration(seconds: 3);

  static double spacingAfterLogo = 22.h;

  static double spacingAfterAppName = 60.h;

  static double spacingAfterDescription = 12.h;

  static double bottomSpacing = 60.h;
}
