import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/spacing.dart';
import 'colors.dart';

class BookmarkDecorations {
  BookmarkDecorations._();

  static BoxDecoration tabContainer({required bool isActive}) => BoxDecoration(
    color:
        isActive
            ? ColorsManager.primaryGreen
            : ColorsManager.lightGray.withOpacity(0.3),
    borderRadius: BorderRadius.circular(12.r),
  );

  static BoxDecoration searchCard() => BoxDecoration(
    color: ColorsManager.cardBackground,
    borderRadius: BorderRadius.circular(Spacing.cardRadius),
    boxShadow: [
      BoxShadow(
        color: ColorsManager.black.withOpacity(0.08),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration collectionsContainer() => BoxDecoration(
    color: ColorsManager.secondaryBackground,
    borderRadius: BorderRadius.circular(16.r),
  );

  static BoxDecoration collectionChip({required bool isSelected}) =>
      BoxDecoration(
        color: isSelected ? ColorsManager.primaryPurple : Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color:
              isSelected
                  ? ColorsManager.primaryPurple
                  : ColorsManager.mediumGray.withOpacity(0.35),
          width: 1,
        ),
      );

  static BoxDecoration shimmerItem() => BoxDecoration(
    color: ColorsManager.lightGray,
    borderRadius: BorderRadius.circular(16.r),
  );

  static BoxDecoration notesContainer() => BoxDecoration(
    color: ColorsManager.mediumGray.withOpacity(0.4),
    borderRadius: BorderRadius.circular(12.r),
  );

  static BoxDecoration hadithCard() => BoxDecoration(
    gradient: LinearGradient(
      colors: [ColorsManager.secondaryBackground, ColorsManager.offWhite],
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
    ),
    borderRadius: BorderRadius.circular(22.r),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration pill(List<Color> colors) => BoxDecoration(
    gradient: LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16.r),
  );

  static BoxDecoration iconCircleGradient() => BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      colors: [ColorsManager.primaryPurple, ColorsManager.secondaryPurple],
    ),
  );

  static BoxDecoration outlinedButtonContainer() => BoxDecoration(
    border: Border.all(
      color: ColorsManager.primaryPurple.withOpacity(0.3),
      width: 1.5,
    ),
    borderRadius: BorderRadius.circular(12.r),
    color: Colors.transparent,
  );
}
