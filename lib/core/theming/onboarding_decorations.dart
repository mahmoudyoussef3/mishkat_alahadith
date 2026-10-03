import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingDecorations {
  static const Color primaryPurple = Color(0xFF7440E9);

  static const Color lightPurple = Color(0xFF9B6FFF);

  static const Color titleTextColor = Color(0xFF2D3748);

  static const Color descriptionTextColor = Color(0xFF718096);

  static LinearGradient primaryGradient() {
    return const LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [primaryPurple, lightPurple],
    );
  }

  static LinearGradient logoGradient() {
    return LinearGradient(
      colors: [primaryPurple, primaryPurple.withOpacity(0.8)],
    );
  }

  static BoxDecoration scaffoldBackgroundDecoration(Gradient pageGradient) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          pageGradient.colors.first.withOpacity(0.08),
          Colors.white,
          pageGradient.colors.last.withOpacity(0.03),
        ],
      ),
    );
  }

  static EdgeInsets headerPadding = EdgeInsets.symmetric(
    horizontal: 20.w,
    vertical: 16.h,
  );

  static BoxDecoration logoContainerDecoration() {
    return BoxDecoration(
      gradient: logoGradient(),
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: primaryPurple.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static double logoWidth = 40.w;
  static double logoHeight = 40.h;

  static const IconData logoIcon = Icons.menu_book_rounded;
  static Color get logoIconColor => Colors.white;
  static double logoIconSize = 20.sp;

  static ButtonStyle skipButtonStyle() {
    return TextButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      backgroundColor: ColorsManager.lightGray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
    );
  }

  static EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 20.w);

  static double spacingAfterImage = 24.h;

  static double spacingAfterText = 20.h;

  static double spacingAtTopOfPage = 20.h;

  static double largeCircleSize = 80.w;
  static double smallCircleSize = 60.w;

  static double largeCircleTop = 40.h;
  static double largeCircleRight = 30.w;

  static double smallCircleBottom = 60.h;
  static double smallCircleLeft = 20.w;

  static BoxDecoration decorativeCircleDecoration(Gradient gradient) {
    return BoxDecoration(shape: BoxShape.circle, gradient: gradient);
  }

  static BoxDecoration islamicPatternContainerDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(32.r),
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
      ),
    );
  }

  static BoxDecoration mainImageContainerDecoration(Gradient gradient) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(24.r),
      gradient: gradient,
      boxShadow: [
        BoxShadow(
          color: gradient.colors.first.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 10),
          spreadRadius: 0,
        ),
      ],
    );
  }

  static double mainImageWidth = 260.w;
  static double mainImageHeight = 260.h;

  static double imageBorderRadius = 24.r;

  static BoxDecoration imageGradientOverlayDecoration(Gradient gradient) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, gradient.colors.first.withOpacity(0.7)],
      ),
    );
  }

  static double iconOverlayBottom = 20.h;
  static double iconOverlayRight = 20.w;

  static BoxDecoration iconOverlayContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static double iconOverlayWidth = 56.w;
  static double iconOverlayHeight = 56.h;

  static double iconOverlayIconSize = 28.sp;

  static BoxDecoration subtitleContainerDecoration(Gradient gradient) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(20.r),
    );
  }

  static EdgeInsets subtitlePaddingSmall = EdgeInsets.symmetric(
    horizontal: 16.w,
    vertical: 6.h,
  );

  static EdgeInsets subtitlePaddingNormal = EdgeInsets.symmetric(
    horizontal: 20.w,
    vertical: 8.h,
  );

  static double spacingAfterTitleSmall = 8.h;

  static double spacingAfterTitleNormal = 12.h;

  static double spacingAfterSubtitleSmall = 12.h;

  static double spacingAfterSubtitleNormal = 16.h;

  static EdgeInsets descriptionPadding = EdgeInsets.symmetric(horizontal: 8.w);

  static const int titleMaxLines = 2;
  static const int subtitleMaxLines = 1;
  static int descriptionMaxLinesSmall = 3;
  static int descriptionMaxLinesNormal = 4;

  static EdgeInsets bottomNavigationPadding = EdgeInsets.all(24.w);

  static double spacingBetweenIndicatorsAndButtons = 32.h;

  static const IconData backButtonIcon = Icons.arrow_back_ios;
  static double backButtonIconSize = 16.sp;

  static BoxDecoration nextButtonDecoration(Gradient gradient) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(24.r),
      boxShadow: [
        BoxShadow(
          color: gradient.colors.first.withOpacity(0.4),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static ButtonStyle nextButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      shadowColor: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
    );
  }

  static const IconData nextIcon = Icons.arrow_forward_ios;
  static const IconData startIcon = Icons.rocket_launch_outlined;
  static double nextButtonIconSize = 16.sp;

  static double nextButtonIconSpacing = 8.w;

  static double backButtonFallbackWidth = 80.w;

  static double activeIndicatorWidth = 32.w;

  static double inactiveIndicatorWidth = 8.w;

  static double indicatorHeight = 8.h;

  static EdgeInsets indicatorMargin = EdgeInsets.symmetric(horizontal: 4.w);

  static double indicatorBorderRadius = 4.r;

  static BoxDecoration activeIndicatorDecoration(Gradient gradient) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(indicatorBorderRadius),
      boxShadow: [
        BoxShadow(
          color: gradient.colors.first.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static Color get inactiveIndicatorColor => ColorsManager.mediumGray;

  static const Duration pageChangeDuration = Duration(milliseconds: 100);

  static const Curve pageChangeCurve = Curves.easeIn;

  static const Duration animationDuration = Duration(milliseconds: 400);

  static const Duration animationResetDelay = Duration(milliseconds: 50);

  static const Duration backButtonDuration = Duration(milliseconds: 800);

  static const Curve backButtonCurve = Curves.easeInOutCubic;

  static const Duration indicatorAnimationDuration = Duration(
    milliseconds: 600,
  );

  static const Curve indicatorAnimationCurve = Curves.easeInOutCubic;

  static const double smallScreenThreshold = 700;
}
