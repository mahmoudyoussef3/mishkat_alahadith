import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class SeragDecorations {
  static Color get scaffoldBackground => ColorsManager.secondaryBackground;

  static EdgeInsets messageBubblePadding = EdgeInsets.only(
    bottom: 12.h,
    left: 8.w,
    right: 8.w,
  );

  static Color get userAvatarBackground => ColorsManager.primaryPurple;

  static Color get userAvatarIconColor => Colors.white;

  static double userAvatarIconSize = 18.sp;

  static double userAvatarRadius = 16.r;

  static const String assistantAvatarPath = 'assets/images/serag_logo.jpg';

  static double assistantAvatarRadius = 16.r;

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

  static EdgeInsets messageBubbleInternalPadding = EdgeInsets.symmetric(
    horizontal: 16.w,
    vertical: 12.h,
  );

  static Color get snackbarCopyBackground => ColorsManager.primaryPurple;

  static const SnackBarBehavior snackbarBehavior = SnackBarBehavior.floating;

  static RoundedRectangleBorder snackbarShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(10),
  );

  static EdgeInsets snackbarMargin = EdgeInsets.all(16.w);

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

  static EdgeInsets inputSectionPadding(BuildContext context) {
    return EdgeInsets.only(
      left: 16.w,
      right: 16.w,
      top: 8.h,
      bottom: MediaQuery.of(context).padding.bottom,
    );
  }

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

  static const InputBorder textFieldBorder = InputBorder.none;

  static EdgeInsets textFieldPadding = EdgeInsets.symmetric(horizontal: 20.w);

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

  static double sendButtonSize = 50.w;

  static double sendButtonHeight = 50.h;

  static double loadingIndicatorSize = 20.w;

  static double loadingIndicatorHeight = 20.h;

  static Color get loadingIndicatorColor => Colors.white;

  static const double loadingIndicatorStrokeWidth = 2.5;

  static Color get sendButtonIconColor => Colors.white;

  static Color get errorSnackbarBackground => Colors.red;

  static Color get limitExceededSnackbarBackground => Colors.red.shade300;

  static Color get dividerColor => ColorsManager.mediumGray;

  static double dividerIndent = 50.w;

  static double dividerEndIndent = 50.w;

  static EdgeInsets warningDisclaimerPadding = EdgeInsets.symmetric(
    horizontal: 16.w,
    vertical: 8.h,
  );

  static double emptyStateIconSize = 64.sp;

  static Color get emptyStateIconColor => ColorsManager.primaryPurple.withOpacity(
    0.3,
  );

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

  static EdgeInsets remainingQuestionsCardMargin = EdgeInsets.all(16.w);

  static EdgeInsets remainingQuestionsCardPadding = EdgeInsets.symmetric(
    vertical: 12.h,
    horizontal: 16.w,
  );

  static Color get iconContainerBackground => ColorsManager.primaryPurple;

  static EdgeInsets iconContainerPadding = EdgeInsets.all(8.w);

  static const double iconContainerBorderRadius = 8;

  static Color get iconColor => Colors.white;

  static double iconSize = 18.sp;

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

  static const Duration shimmerAnimationDuration = Duration(milliseconds: 1500);

  static List<Color> get shimmerGradientColors => [
    ColorsManager.primaryPurple.withOpacity(0.1),
    ColorsManager.primaryPurple.withOpacity(0.3),
    ColorsManager.primaryPurple.withOpacity(0.1),
  ];

  static BoxDecoration noAttemptsContainer() {
    return BoxDecoration(
      color:
          ColorsManager.isDark
              ? ColorsManager.error.withOpacity(0.12)
              : Colors.red.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color:
            ColorsManager.isDark
                ? ColorsManager.error.withOpacity(0.4)
                : Colors.red.shade200,
      ),
    );
  }

  static const EdgeInsets noAttemptsContainerPadding = EdgeInsets.all(16);

  static const EdgeInsets noAttemptsContainerMargin = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );

  static Color get noAttemptsWarningIconColor => Colors.red;

  static const IconData noAttemptsWarningIcon = Icons.warning_amber_rounded;
}
