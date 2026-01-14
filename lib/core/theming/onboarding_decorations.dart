import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Onboarding feature decorations
/// Extracted from onboarding_screen for consistent styling
class OnboardingDecorations {
  // ==================== COLORS ====================

  /// Primary purple color
  static const Color primaryPurple = Color(0xFF7440E9);

  /// Light purple color
  static const Color lightPurple = Color(0xFF9B6FFF);

  /// Title text color
  static const Color titleTextColor = Color(0xFF2D3748);

  /// Description text color
  static const Color descriptionTextColor = Color(0xFF718096);

  // ==================== GRADIENTS ====================

  /// Primary gradient (purple theme)
  static LinearGradient primaryGradient() {
    return const LinearGradient(
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      colors: [primaryPurple, lightPurple],
    );
  }

  /// Logo gradient for header
  static LinearGradient logoGradient() {
    return LinearGradient(
      colors: [primaryPurple, primaryPurple.withOpacity(0.8)],
    );
  }

  // ==================== SCAFFOLD ====================

  /// Scaffold background gradient
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

  // ==================== HEADER ====================

  /// Header padding
  static EdgeInsets headerPadding = EdgeInsets.symmetric(
    horizontal: 20.w,
    vertical: 16.h,
  );

  /// Logo container decoration
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

  /// Logo container size
  static double logoWidth = 40.w;
  static double logoHeight = 40.h;

  /// Logo icon
  static const IconData logoIcon = Icons.menu_book_rounded;
  static const Color logoIconColor = Colors.white;
  static double logoIconSize = 20.sp;

  /// Skip button decoration
  static ButtonStyle skipButtonStyle() {
    return TextButton.styleFrom(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      backgroundColor: Colors.grey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
    );
  }

  // ==================== PAGE CONTENT ====================

  /// Page padding
  static EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 20.w);

  /// Spacing after image section
  static double spacingAfterImage = 24.h;

  /// Spacing after text content
  static double spacingAfterText = 20.h;

  /// Spacing at top of page
  static double spacingAtTopOfPage = 20.h;

  // ==================== IMAGE SECTION ====================

  /// Decorative circle sizes
  static double largeCircleSize = 80.w;
  static double smallCircleSize = 60.w;

  /// Large circle position
  static double largeCircleTop = 40.h;
  static double largeCircleRight = 30.w;

  /// Small circle position
  static double smallCircleBottom = 60.h;
  static double smallCircleLeft = 20.w;

  /// Decorative circle decoration
  static BoxDecoration decorativeCircleDecoration(Gradient gradient) {
    return BoxDecoration(shape: BoxShape.circle, gradient: gradient);
  }

  /// Islamic pattern container decoration
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

  /// Main image container decoration
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

  /// Main image container size
  static double mainImageWidth = 260.w;
  static double mainImageHeight = 260.h;

  /// Image border radius
  static double imageBorderRadius = 24.r;

  /// Image gradient overlay decoration
  static BoxDecoration imageGradientOverlayDecoration(Gradient gradient) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, gradient.colors.first.withOpacity(0.7)],
      ),
    );
  }

  /// Icon overlay position
  static double iconOverlayBottom = 20.h;
  static double iconOverlayRight = 20.w;

  /// Icon overlay container decoration
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

  /// Icon overlay container size
  static double iconOverlayWidth = 56.w;
  static double iconOverlayHeight = 56.h;

  /// Icon overlay icon size
  static double iconOverlayIconSize = 28.sp;

  // ==================== TEXT CONTENT ====================

  /// Subtitle container decoration
  static BoxDecoration subtitleContainerDecoration(Gradient gradient) {
    return BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(20.r),
    );
  }

  /// Subtitle padding (small screen)
  static EdgeInsets subtitlePaddingSmall = EdgeInsets.symmetric(
    horizontal: 16.w,
    vertical: 6.h,
  );

  /// Subtitle padding (normal screen)
  static EdgeInsets subtitlePaddingNormal = EdgeInsets.symmetric(
    horizontal: 20.w,
    vertical: 8.h,
  );

  /// Spacing after title (small screen)
  static double spacingAfterTitleSmall = 8.h;

  /// Spacing after title (normal screen)
  static double spacingAfterTitleNormal = 12.h;

  /// Spacing after subtitle (small screen)
  static double spacingAfterSubtitleSmall = 12.h;

  /// Spacing after subtitle (normal screen)
  static double spacingAfterSubtitleNormal = 16.h;

  /// Description padding
  static EdgeInsets descriptionPadding = EdgeInsets.symmetric(horizontal: 8.w);

  /// Text max lines
  static const int titleMaxLines = 2;
  static const int subtitleMaxLines = 1;
  static int descriptionMaxLinesSmall = 3;
  static int descriptionMaxLinesNormal = 4;

  // ==================== BOTTOM NAVIGATION ====================

  /// Bottom navigation padding
  static EdgeInsets bottomNavigationPadding = EdgeInsets.all(24.w);

  /// Spacing between indicators and buttons
  static double spacingBetweenIndicatorsAndButtons = 32.h;

  /// Back button icon
  static const IconData backButtonIcon = Icons.arrow_back_ios;
  static double backButtonIconSize = 16.sp;

  /// Next button decoration
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

  /// Next button style
  static ButtonStyle nextButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      shadowColor: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
    );
  }

  /// Next button icon
  static const IconData nextIcon = Icons.arrow_forward_ios;
  static const IconData startIcon = Icons.rocket_launch_outlined;
  static double nextButtonIconSize = 16.sp;

  /// Next button spacing
  static double nextButtonIconSpacing = 8.w;

  /// Back button fallback width
  static double backButtonFallbackWidth = 80.w;

  // ==================== PAGE INDICATORS ====================

  /// Active indicator width
  static double activeIndicatorWidth = 32.w;

  /// Inactive indicator width
  static double inactiveIndicatorWidth = 8.w;

  /// Indicator height
  static double indicatorHeight = 8.h;

  /// Indicator margin
  static EdgeInsets indicatorMargin = EdgeInsets.symmetric(horizontal: 4.w);

  /// Indicator border radius
  static double indicatorBorderRadius = 4.r;

  /// Active indicator decoration
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

  /// Inactive indicator color
  static Color inactiveIndicatorColor = Colors.grey.shade300;

  // ==================== ANIMATION ====================

  /// Page change animation duration
  static const Duration pageChangeDuration = Duration(milliseconds: 100);

  /// Page change animation curve
  static const Curve pageChangeCurve = Curves.easeIn;

  /// Animation controller duration
  static const Duration animationDuration = Duration(milliseconds: 400);

  /// Animation reset delay
  static const Duration animationResetDelay = Duration(milliseconds: 50);

  /// Back button animation duration
  static const Duration backButtonDuration = Duration(milliseconds: 800);

  /// Back button animation curve
  static const Curve backButtonCurve = Curves.easeInOutCubic;

  /// Page indicator animation duration
  static const Duration indicatorAnimationDuration = Duration(
    milliseconds: 600,
  );

  /// Page indicator animation curve
  static const Curve indicatorAnimationCurve = Curves.easeInOutCubic;

  // ==================== SCREEN SIZE ====================

  /// Small screen threshold
  static const double smallScreenThreshold = 700;
}
