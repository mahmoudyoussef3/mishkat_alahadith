import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';
import 'decorations.dart';

class HadithDecorations {
  HadithDecorations._();

  static BoxDecoration chapterCard(Color gradeColor) => BoxDecoration(
    color: ColorsManager.cardBackground,
    borderRadius: BorderRadius.circular(20.r),
    border: Border.all(color: ColorsManager.mediumGray),
    boxShadow: Decorations.cardShadow,
  );

  static BoxDecoration patternOverlay(Color gradeColor, double radius) =>
      BoxDecoration(
        color: gradeColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(radius.r),
      );

  static BoxDecoration headerIcon(Color gradeColor) => BoxDecoration(
    color: gradeColor.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(12.r),
  );

  static BoxDecoration gradeBadge(Color gradeColor) => BoxDecoration(
    color: gradeColor.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(20.r),
  );

  /// The hadith text sits directly on the card: no nested box competing
  /// with the words for attention.
  static BoxDecoration hadithTextContainer(Color gradeColor) =>
      const BoxDecoration();

  /// Soft tinted pill; pair it with text in the same hue at full strength.
  static BoxDecoration pill(List<Color> colors) => BoxDecoration(
    color: colors.first.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(20.r),
  );

  static BoxDecoration bottomLine(Color gradeColor) => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        gradeColor.withValues(alpha: 0.25),
        gradeColor.withValues(alpha: 0),
      ],
    ),
    borderRadius: BorderRadius.circular(1.r),
  );

  static BoxDecoration emptyStateCard() => BoxDecoration(
    gradient: LinearGradient(
      colors: [ColorsManager.cardBackground, ColorsManager.offWhite.withOpacity(0.8)],
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

  static BoxDecoration quoteChip() => BoxDecoration(
    color: ColorsManager.primaryPurple.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12.r),
  );
}
