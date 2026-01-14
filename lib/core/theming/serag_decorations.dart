import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

/// Serag Chat feature decorations
/// Extracted from serag screens and widgets for consistent styling
class SeragDecorations {
  // ==================== CHAT SCREEN ====================

  /// Main scaffold background color
  static const Color scaffoldBackground = ColorsManager.secondaryBackground;

  // ==================== CHAT MESSAGE BUBBLE ====================

  /// Message bubble padding
  static EdgeInsets messageBubblePadding = EdgeInsets.only(
    bottom: 12.h,
    left: 8.w,
    right: 8.w,
  );

  /// User avatar background color
  static const Color userAvatarBackground = ColorsManager.primaryPurple;

  /// User avatar icon color
  static const Color userAvatarIconColor = Colors.white;

  /// User avatar icon size
  static double userAvatarIconSize = 18.sp;

  /// User avatar radius
  static double userAvatarRadius = 16.r;

  /// Assistant avatar image path
  static const String assistantAvatarPath = 'assets/images/serag_logo.jpg';

  /// Assistant avatar radius
  static double assistantAvatarRadius = 16.r;

  /// User message bubble decoration (gradient)
  static BoxDecoration userMessageBubble() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          ColorsManager.primaryPurple,
          ColorsManager.primaryPurple.withOpacity(0.8),
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.r),
        topRight: Radius.circular(20.r),
        bottomLeft: Radius.circular(20.r),
        bottomRight: Radius.circular(4.r),
      ),
      boxShadow: [
        BoxShadow(
          color: ColorsManager.primaryPurple.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Assistant message bubble decoration
  static BoxDecoration assistantMessageBubble() {
    return BoxDecoration(
      color: ColorsManager.secondaryBackground,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.r),
        topRight: Radius.circular(20.r),
        bottomLeft: Radius.circular(4.r),
        bottomRight: Radius.circular(20.r),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Message bubble padding (internal)
  static EdgeInsets messageBubbleInternalPadding = EdgeInsets.symmetric(
    horizontal: 16.w,
    vertical: 12.h,
  );

  /// Snackbar copy message background
  static const Color snackbarCopyBackground = ColorsManager.primaryPurple;

  /// Snackbar copy message behavior
  static const SnackBarBehavior snackbarBehavior = SnackBarBehavior.floating;

  /// Snackbar copy message shape
  static RoundedRectangleBorder snackbarShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  );

  /// Snackbar margin
  static EdgeInsets snackbarMargin = EdgeInsets.all(16.w);

  // ==================== CHAT INPUT SECTION ====================

  /// Input section container decoration
  static BoxDecoration inputSectionContainer() {
    return BoxDecoration(
      color: ColorsManager.primaryBackground,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    );
  }

  /// Input section padding
  static EdgeInsets inputSectionPadding(BuildContext context) {
    return EdgeInsets.only(
      left: 16.w,
      right: 16.w,
      top: 8.h,
      bottom: MediaQuery.of(context).padding.bottom,
    );
  }

  /// Text field container decoration
  static BoxDecoration textFieldContainer() {
    return BoxDecoration(
      color: ColorsManager.secondaryBackground,
      borderRadius: BorderRadius.circular(25.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Text field border
  static const InputBorder textFieldBorder = InputBorder.none;

  /// Text field content padding
  static EdgeInsets textFieldPadding = EdgeInsets.symmetric(horizontal: 20.w);

  /// Send button gradient decoration
  static BoxDecoration sendButtonGradient() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          ColorsManager.primaryPurple,
          ColorsManager.primaryPurple.withOpacity(0.8),
        ],
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      ),
      borderRadius: BorderRadius.circular(25.r),
      boxShadow: [
        BoxShadow(
          color: ColorsManager.primaryPurple.withOpacity(0.4),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Send button size
  static double sendButtonSize = 50.w;

  /// Send button height
  static double sendButtonHeight = 50.h;

  /// Loading indicator size
  static double loadingIndicatorSize = 20.w;

  /// Loading indicator height
  static double loadingIndicatorHeight = 20.h;

  /// Loading indicator color
  static const Color loadingIndicatorColor = Colors.white;

  /// Loading indicator stroke width
  static const double loadingIndicatorStrokeWidth = 2.5;

  /// Send button icon color
  static const Color sendButtonIconColor = Colors.white;

  /// Error snackbar background color
  static const Color errorSnackbarBackground = Colors.red;

  /// Limit exceeded snackbar background color
  static Color limitExceededSnackbarBackground = Colors.red.shade300;

  /// Divider color
  static const Color dividerColor = ColorsManager.mediumGray;

  /// Divider indent
  static double dividerIndent = 50.w;

  /// Divider end indent
  static double dividerEndIndent = 50.w;

  /// Warning disclaimer padding
  static EdgeInsets warningDisclaimerPadding = EdgeInsets.symmetric(
    horizontal: 16.w,
    vertical: 8.h,
  );

  // ==================== EMPTY CHAT STATE ====================

  /// Empty state icon size
  static double emptyStateIconSize = 64.sp;

  /// Empty state icon color
  static Color emptyStateIconColor = ColorsManager.primaryPurple.withOpacity(
    0.3,
  );

  // ==================== REMAINING QUESTIONS CARD ====================

  /// Card container decoration
  static BoxDecoration remainingQuestionsCard() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          ColorsManager.primaryPurple.withOpacity(0.1),
          ColorsManager.primaryPurple.withOpacity(0.05),
        ],
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: ColorsManager.primaryPurple.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  /// Card margin
  static EdgeInsets remainingQuestionsCardMargin = EdgeInsets.all(16.w);

  /// Card padding
  static EdgeInsets remainingQuestionsCardPadding = EdgeInsets.symmetric(
    vertical: 12.h,
    horizontal: 16.w,
  );

  /// Icon container background color
  static const Color iconContainerBackground = ColorsManager.primaryPurple;

  /// Icon container padding
  static EdgeInsets iconContainerPadding = EdgeInsets.all(8.w);

  /// Icon container border radius
  static const double iconContainerBorderRadius = 8;

  /// Icon color
  static const Color iconColor = Colors.white;

  /// Icon size
  static double iconSize = 18.sp;

  /// Shimmer loading card decoration
  static BoxDecoration shimmerLoadingCard() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: ColorsManager.primaryPurple.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  /// Shimmer animation duration
  static const Duration shimmerAnimationDuration = Duration(milliseconds: 1500);

  /// Shimmer gradient colors
  static List<Color> shimmerGradientColors = [
    ColorsManager.primaryPurple.withOpacity(0.1),
    ColorsManager.primaryPurple.withOpacity(0.3),
    ColorsManager.primaryPurple.withOpacity(0.1),
  ];

  // ==================== NO ATTEMPTS LEFT WIDGET ====================

  /// No attempts container decoration
  static BoxDecoration noAttemptsContainer() {
    return BoxDecoration(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.red.shade200),
    );
  }

  /// No attempts container padding
  static const EdgeInsets noAttemptsContainerPadding = EdgeInsets.all(16);

  /// No attempts container margin
  static const EdgeInsets noAttemptsContainerMargin = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );

  /// No attempts warning icon color
  static const Color noAttemptsWarningIconColor = Colors.red;

  /// No attempts warning icon
  static const IconData noAttemptsWarningIcon = Icons.warning_amber_rounded;
}
