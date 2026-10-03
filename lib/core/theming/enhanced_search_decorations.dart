import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class EnhancedSearchDecorations {
  static RoundedRectangleBorder seragFabShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  );

  static Color get seragFabBackgroundColor => ColorsManager.primaryPurple;

  static const double seragFabElevation = 10;

  static const String seragLogoPath = 'assets/images/serag_logo.jpg';

  static Color get loginSnackbarBackground => ColorsManager.primaryGreen;

  static Color get dividerColor => ColorsManager.gray;

  static BoxDecoration enhancedTabsSection() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: ColorsManager.primaryPurple.withOpacity(0.08),
          blurRadius: 20.r,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration tabContentContainer() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: ColorsManager.gray),
    );
  }

  static BoxDecoration enhancedActionsSection() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          ColorsManager.primaryGreen.withOpacity(0.1),
          ColorsManager.primaryPurple.withOpacity(0.05),
        ],
      ),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(
        color: ColorsManager.primaryGold.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  static const IconData titleIcon = Icons.auto_stories;
  static Color get titleIconColor => ColorsManager.primaryPurple;
  static double titleIconSize = 24.sp;

  static Color get wordDialogBackground => ColorsManager.secondaryBackground;

  static Color gradeChipBackground(Color gradeColor) {
    return gradeColor.withOpacity(0.1);
  }

  static BoxDecoration selectedTab() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    );
  }

  static BoxDecoration unselectedTab() {
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
    );
  }

  static BoxDecoration hadithContentCard() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          ColorsManager.secondaryBackground,
          ColorsManager.primaryPurple.withOpacity(0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(
        color: ColorsManager.primaryPurple.withOpacity(0.15),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: ColorsManager.primaryPurple.withOpacity(0.08),
          blurRadius: 20.r,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static const double islamicPatternOpacity = 0.0005;

  static const String islamicPatternPath = 'assets/images/islamic_pattern.jpg';

  static BoxDecoration hadithLabel() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(
        color: ColorsManager.primaryPurple.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  static Color get labelIconColor => ColorsManager.primaryPurple;

  static Color get copyIconColor => ColorsManager.primaryPurple;

  static Color get shareIconColor => ColorsManager.primaryGreen;

  static BoxDecoration actionIconContainer(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: color.withOpacity(0.2)),
    );
  }

  static BoxDecoration topRightCornerDecoration() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withOpacity(0.1),
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(20.r),
        bottomLeft: Radius.circular(20.r),
      ),
    );
  }

  static const IconData topRightCornerIcon = Icons.format_quote;
  static Color get topRightCornerIconColor => ColorsManager.primaryPurple
      .withOpacity(0.6);
  static double topRightCornerIconSize = 24.sp;

  static BoxDecoration hadithContentLabelContainer() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(
        color: ColorsManager.primaryPurple.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  static const IconData hadithContentLabelIcon = Icons.auto_stories;
  static Color get hadithContentLabelIconColor => ColorsManager.primaryPurple;
  static double hadithContentLabelIconSize = 16.sp;

  static const IconData copyIcon = Icons.copy_rounded;

  static const IconData shareIcon = Icons.share_rounded;

  static const SnackBarBehavior snackbarBehavior = SnackBarBehavior.floating;

  static BoxDecoration actionRowContainer() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: ColorsManager.primaryPurple.withOpacity(0.1),
    );
  }

  static Color get actionButtonCircleBackground => ColorsManager.primaryPurple
      .withOpacity(0.1);

  static Color get actionButtonIconColor => ColorsManager.primaryPurple;

  static Color get actionButtonBackground => ColorsManager.primaryPurple.withOpacity(
    0.1,
  );

  static Color get successSnackbarBackground => Colors.green;

  static Color get errorSnackbarBackground => Colors.red;

  static Color get loadingSnackbarBackground => ColorsManager.primaryGreen;

  static Color get snackBarLoadingColor => ColorsManager.primaryGreen;
  static Color get snackBarSuccessColor => Colors.green;
  static Color get snackBarErrorColor => Colors.red;
  static Color get snackBarLoginColor => ColorsManager.primaryGreen;
  static Color get snackBarIconColor => Colors.white;
}
