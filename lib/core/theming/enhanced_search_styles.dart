import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

/// Enhanced Public Search feature text styles
/// Extracted from enhanced_public_search screens and widgets for consistent styling
class EnhancedSearchTextStyles {
  // ==================== HADITH RESULT DETAILS SCREEN ====================

  /// Serag FAB label text
  static TextStyle seragFabLabel = TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.secondaryBackground,
  );

  /// Login required snackbar text
  static TextStyle loginRequiredSnackbar = TextStyle(
    color: ColorsManager.secondaryBackground,
  );

  /// Login button text in snackbar
  static const TextStyle loginButtonSnackbar = TextStyle(color: Colors.white);

  // ==================== RESULT HADITH TITLE ====================

  /// Hadith title text
  static const TextStyle hadithTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryPurple,
  );

  // ==================== RESULT HADITH RICH TEXT ====================

  /// Special word (highlighted) text style
  static const TextStyle specialWord = TextStyle(
    fontSize: 20,
    fontFamily: "Amiri",
    height: 1.8,
    color: ColorsManager.primaryPurple,
    fontWeight: FontWeight.bold,
  );

  /// Regular word text style
  static const TextStyle regularWord = TextStyle(
    fontSize: 20,
    fontFamily: "Amiri",
    height: 1.8,
    color: Colors.black87,
    fontWeight: FontWeight.w400,
  );

  /// Word dialog title
  static const TextStyle wordDialogTitle = TextStyle(
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryPurple,
  );

  // ==================== SEARCH HADITH ATTRIBUTION AND GRADE ====================

  /// Attribution text style (with book icon)
  static const TextStyle attribution = TextStyle(
    fontSize: 16,
    color: ColorsManager.accentPurple,
    fontStyle: FontStyle.italic,
  );

  /// Grade chip text style
  static TextStyle gradeChipText(Color color) {
    return TextStyle(color: color, fontWeight: FontWeight.bold);
  }

  // ==================== RESULT HADITH TAB CONTENT ====================

  /// Explanation text
  static const TextStyle explanationText = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w500,
    color: ColorsManager.black,
    height: 1.6,
  );

  /// Hints/lessons counter text
  static const TextStyle hintsCounter = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w500,
    color: ColorsManager.black,
  );

  /// Hints/lessons content text
  static const TextStyle hintsContent = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w500,
    color: ColorsManager.black,
  );

  /// Word meaning - word text
  static const TextStyle wordMeaningWord = TextStyle(
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w700,
    color: ColorsManager.darkPurple,
  );

  /// Word meaning - colon separator
  static const TextStyle wordMeaningSeparator = TextStyle(
    fontWeight: FontWeight.bold,
    color: ColorsManager.darkPurple,
  );

  /// Word meaning - meaning text
  static const TextStyle wordMeaningText = TextStyle(
    fontSize: 15,
    fontFamily: 'Cairo',
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );

  /// Empty state text
  static const TextStyle emptyStateText = TextStyle();

  // ==================== RESULT HADITH TABS ====================

  /// Selected tab text
  static TextStyle selectedTabText = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primaryPurple,
  );

  /// Unselected tab text
  static TextStyle unselectedTabText = TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
  );

  // ==================== RESULT HADITH CONTENT CARD ====================

  /// "نص الحديث" label text
  static TextStyle hadithContentLabel = TextStyle(
    color: ColorsManager.primaryPurple,
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );

  /// Hadith label text (same as hadithContentLabel)
  static TextStyle hadithLabelText = TextStyle(
    color: ColorsManager.primaryPurple,
    fontSize: 12.sp,
    fontWeight: FontWeight.bold,
  );

  /// Snackbar success message
  static const TextStyle snackbarSuccess = TextStyle();

  // ==================== RESULT HADITH ACTION ROW ====================

  /// Action button label
  static TextStyle actionButtonLabel = TextStyle(
    fontSize: 13.sp,
    color: ColorsManager.darkGray,
  );

  /// Snackbar text
  static const TextStyle snackBarText = TextStyle(
    color: ColorsManager.secondaryBackground,
  );

  /// Success snackbar text
  static const TextStyle actionSuccessSnackbar = TextStyle();

  /// Error snackbar text
  static const TextStyle actionErrorSnackbar = TextStyle();
}
