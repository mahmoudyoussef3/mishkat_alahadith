import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

/// HadithDecorations centralizes BoxDecoration patterns used across Hadith UI.
/// Naming indicates context to keep code discoverable and reusable.
class HadithDecorations {
  HadithDecorations._();

  /// Main Hadith card container (grade-aware).
  static BoxDecoration chapterCard(Color gradeColor) => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        ColorsManager.secondaryBackground,
        ColorsManager.offWhite,
        ColorsManager.lightGray.withOpacity(0.3),
      ],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ),
    borderRadius: BorderRadius.circular(26.r),
    border: Border.all(color: gradeColor.withOpacity(0.15), width: 1.5),
    boxShadow: [
      BoxShadow(
        color: gradeColor.withOpacity(0.08),
        blurRadius: 15,
        offset: const Offset(0, 6),
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// Decorative pattern bubble overlay (grade-aware).
  static BoxDecoration patternOverlay(Color gradeColor, double radius) =>
      BoxDecoration(
        color: gradeColor.withOpacity(0.03),
        borderRadius: BorderRadius.circular(radius.r),
      );

  /// Header icon container (grade-aware).
  static BoxDecoration headerIcon(Color gradeColor) => BoxDecoration(
    gradient: LinearGradient(
      colors: [gradeColor.withOpacity(0.1), gradeColor.withOpacity(0.05)],
    ),
    borderRadius: BorderRadius.circular(12.r),
  );

  /// Grade badge chip (grade-aware).
  static BoxDecoration gradeBadge(Color gradeColor) => BoxDecoration(
    gradient: LinearGradient(
      colors: [gradeColor.withOpacity(0.15), gradeColor.withOpacity(0.08)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16.r),
    border: Border.all(color: gradeColor.withOpacity(0.2), width: 1),
  );

  /// Hadith text container (grade-aware border).
  static BoxDecoration hadithTextContainer(Color gradeColor) => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        ColorsManager.white.withOpacity(0.8),
        ColorsManager.offWhite.withOpacity(0.6),
      ],
    ),
    borderRadius: BorderRadius.circular(18.r),
    border: Border.all(color: gradeColor.withOpacity(0.1), width: 1),
  );

  /// Gradient pill for tags/chips.
  static BoxDecoration pill(List<Color> colors) => BoxDecoration(
    gradient: LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(20.r),
    boxShadow: [
      BoxShadow(
        color: colors.first.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );

  /// Decorative bottom line (grade-aware).
  static BoxDecoration bottomLine(Color gradeColor) => BoxDecoration(
    gradient: LinearGradient(
      colors: [gradeColor.withOpacity(0.4), gradeColor.withOpacity(0.1)],
    ),
    borderRadius: BorderRadius.circular(1.r),
  );

  /// Empty state card decoration.
  static BoxDecoration emptyStateCard() => BoxDecoration(
    gradient: LinearGradient(
      colors: [ColorsManager.white, ColorsManager.offWhite.withOpacity(0.8)],
    ),
    borderRadius: BorderRadius.circular(24.r),
    border: Border.all(
      color: ColorsManager.primaryPurple.withOpacity(0.1),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: ColorsManager.primaryPurple.withOpacity(0.08),
        blurRadius: 20,
        offset: Offset(0, 8.h),
        spreadRadius: 2,
      ),
    ],
  );

  /// Separator line gradients.
  static BoxDecoration separatorLine({bool reverse = false}) => BoxDecoration(
    gradient: LinearGradient(
      colors:
          reverse
              ? [
                ColorsManager.primaryPurple.withOpacity(0.1),
                ColorsManager.primaryPurple.withOpacity(0.3),
              ]
              : [
                ColorsManager.primaryPurple.withOpacity(0.3),
                ColorsManager.primaryPurple.withOpacity(0.1),
              ],
    ),
    borderRadius: BorderRadius.circular(1.r),
  );

  /// Quote chip in separator.
  static BoxDecoration quoteChip() => BoxDecoration(
    color: ColorsManager.primaryPurple.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12.r),
  );
}
