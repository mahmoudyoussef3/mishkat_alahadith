import 'package:mishkat_almasabih/core/theming/decorations.dart';
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

  static BoxDecoration enhancedTabsSection() => Decorations.tabsTrack();

  static BoxDecoration tabContentContainer() => Decorations.contentPanel();

  static BoxDecoration enhancedActionsSection() => Decorations.contentPanel();

  static const IconData titleIcon = Icons.auto_stories;
  static Color get titleIconColor => ColorsManager.primaryPurple;
  static double titleIconSize = 24.sp;

  static Color get wordDialogBackground => ColorsManager.secondaryBackground;

  static Color gradeChipBackground(Color gradeColor) =>
      gradeColor.withValues(alpha: 0.12);

  static BoxDecoration selectedTab() => Decorations.tabPill(isSelected: true);

  static BoxDecoration unselectedTab() => Decorations.tabPill(isSelected: false);

  static BoxDecoration hadithContentCard() => Decorations.readingCard();

  static const double islamicPatternOpacity = 0.0005;

  static const String islamicPatternPath = 'assets/images/islamic_pattern.jpg';

  static BoxDecoration hadithLabel() =>
      Decorations.softChip(ColorsManager.primaryPurple);

  static Color get labelIconColor => ColorsManager.primaryPurple;

  static Color get copyIconColor => ColorsManager.primaryPurple;

  static Color get shareIconColor => ColorsManager.primaryGreen;

  static BoxDecoration actionIconContainer(Color color) =>
      Decorations.iconWell(color);

  static BoxDecoration topRightCornerDecoration() => BoxDecoration(
    color: ColorsManager.primarySoft,
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(24.r),
      bottomLeft: Radius.circular(20.r),
    ),
  );

  static const IconData topRightCornerIcon = Icons.format_quote;
  static Color get topRightCornerIconColor => ColorsManager.primaryPurple
      .withOpacity(0.6);
  static double topRightCornerIconSize = 24.sp;

  static BoxDecoration hadithContentLabelContainer() =>
      Decorations.softChip(ColorsManager.primaryPurple);

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

  static Color get successSnackbarBackground => ColorsManager.success;

  static Color get errorSnackbarBackground => ColorsManager.error;

  static Color get loadingSnackbarBackground => ColorsManager.primaryGreen;

  static Color get snackBarLoadingColor => ColorsManager.primaryGreen;
  static Color get snackBarSuccessColor => ColorsManager.success;
  static Color get snackBarErrorColor => ColorsManager.error;
  static Color get snackBarLoginColor => ColorsManager.primaryGreen;
  static Color get snackBarIconColor => Colors.white;
}
