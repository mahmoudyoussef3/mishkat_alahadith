import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

/// Enhanced Public Search feature decorations
/// Extracted from enhanced_public_search screens and widgets for consistent styling
class EnhancedSearchDecorations {
  // ==================== HADITH RESULT DETAILS SCREEN ====================

  /// Serag FAB shape
  static RoundedRectangleBorder seragFabShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
  );

  /// Serag FAB background color
  static const Color seragFabBackgroundColor = ColorsManager.primaryPurple;

  /// Serag FAB elevation
  static const double seragFabElevation = 10;

  /// Serag logo path
  static const String seragLogoPath = 'assets/images/serag_logo.jpg';

  /// Login snackbar background color
  static const Color loginSnackbarBackground = ColorsManager.primaryGreen;

  /// Divider color
  static const Color dividerColor = ColorsManager.gray;

  /// Enhanced tabs section decoration
  static BoxDecoration enhancedTabsSection() {
    return BoxDecoration(
      color: ColorsManager.white,
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

  /// Tab content container decoration
  static BoxDecoration tabContentContainer() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: ColorsManager.gray),
    );
  }

  /// Enhanced actions section gradient decoration
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

  // ==================== RESULT HADITH TITLE ====================

  /// Title icon
  static const IconData titleIcon = Icons.auto_stories;
  static Color titleIconColor = ColorsManager.primaryPurple;
  static double titleIconSize = 24.sp;

  // ==================== RESULT HADITH RICH TEXT ====================

  /// Word dialog background color
  static const Color wordDialogBackground = ColorsManager.secondaryBackground;

  // ==================== SEARCH HADITH ATTRIBUTION AND GRADE ====================

  /// Grade chip background color (dynamic based on grade)
  static Color gradeChipBackground(Color gradeColor) {
    return gradeColor.withOpacity(0.1);
  }

  // ==================== RESULT HADITH TABS ====================

  /// Selected tab decoration
  static BoxDecoration selectedTab() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withOpacity(0.2),
      borderRadius: BorderRadius.circular(12),
    );
  }

  /// Unselected tab decoration
  static BoxDecoration unselectedTab() {
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
    );
  }

  // ==================== RESULT HADITH CONTENT CARD ====================

  /// Main hadith content card gradient decoration
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

  /// Islamic pattern overlay opacity
  static const double islamicPatternOpacity = 0.0005;

  /// Islamic pattern asset path
  static const String islamicPatternPath = 'assets/images/islamic_pattern.jpg';

  /// Hadith label decoration
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

  /// Label icon color
  static const Color labelIconColor = ColorsManager.primaryPurple;

  /// Copy icon color
  static const Color copyIconColor = ColorsManager.primaryPurple;

  /// Share icon color
  static const Color shareIconColor = ColorsManager.primaryGreen;

  /// Action icon container decoration
  static BoxDecoration actionIconContainer(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: color.withOpacity(0.2)),
    );
  }

  /// Top right corner decoration
  static BoxDecoration topRightCornerDecoration() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withOpacity(0.1),
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(20.r),
        bottomLeft: Radius.circular(20.r),
      ),
    );
  }

  /// Top right corner icon
  static const IconData topRightCornerIcon = Icons.format_quote;
  static Color topRightCornerIconColor = ColorsManager.primaryPurple
      .withOpacity(0.6);
  static double topRightCornerIconSize = 24.sp;

  /// "نص الحديث" label decoration
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

  /// Hadith content label icon
  static const IconData hadithContentLabelIcon = Icons.auto_stories;
  static const Color hadithContentLabelIconColor = ColorsManager.primaryPurple;
  static double hadithContentLabelIconSize = 16.sp;

  /// Copy icon
  static const IconData copyIcon = Icons.copy_rounded;

  /// Share icon
  static const IconData shareIcon = Icons.share_rounded;

  /// Snackbar behavior
  static const SnackBarBehavior snackbarBehavior = SnackBarBehavior.floating;

  // ==================== RESULT HADITH ACTION ROW ====================

  /// Action row container decoration
  static BoxDecoration actionRowContainer() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      color: ColorsManager.primaryPurple.withOpacity(0.1),
    );
  }

  /// Action button circle avatar background
  static Color actionButtonCircleBackground = ColorsManager.primaryPurple
      .withOpacity(0.1);

  /// Action button icon color
  static const Color actionButtonIconColor = ColorsManager.primaryPurple;

  /// Action button background (simpler name)
  static Color actionButtonBackground = ColorsManager.primaryPurple.withOpacity(
    0.1,
  );

  /// Success snackbar background
  static const Color successSnackbarBackground = Colors.green;

  /// Error snackbar background
  static const Color errorSnackbarBackground = Colors.red;

  /// Loading snackbar background
  static const Color loadingSnackbarBackground = ColorsManager.primaryGreen;

  /// Snackbar colors (shorter names)
  static const Color snackBarLoadingColor = ColorsManager.primaryGreen;
  static const Color snackBarSuccessColor = Colors.green;
  static const Color snackBarErrorColor = Colors.red;
  static const Color snackBarLoginColor = ColorsManager.primaryGreen;
  static const Color snackBarIconColor = Colors.white;
}
