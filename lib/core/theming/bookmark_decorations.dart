import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/helpers/spacing.dart';
import 'colors.dart';

/// BookmarkDecorations centralizes BoxDecoration patterns for the Bookmark feature.
class BookmarkDecorations {
  BookmarkDecorations._();

  /// Tab button container (active/inactive).
  static BoxDecoration tabContainer({required bool isActive}) => BoxDecoration(
    color:
        isActive
            ? ColorsManager.primaryGreen
            : ColorsManager.lightGray.withOpacity(0.3),
    borderRadius: BorderRadius.circular(12.r),
  );

  /// Search card container below app bar.
  static BoxDecoration searchCard() => BoxDecoration(
    color: ColorsManager.white,
    borderRadius: BorderRadius.circular(Spacing.cardRadius),
    boxShadow: [
      BoxShadow(
        color: ColorsManager.black.withOpacity(0.08),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Container for the collections row background.
  static BoxDecoration collectionsContainer() => BoxDecoration(
    color: ColorsManager.secondaryBackground,
    borderRadius: BorderRadius.circular(16.r),
  );

  /// Individual collection chip container.
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

  /// Shimmer placeholder item for collections loading.
  static BoxDecoration shimmerItem() => BoxDecoration(
    color: ColorsManager.lightGray,
    borderRadius: BorderRadius.circular(16.r),
  );

  /// Notes container.
  static BoxDecoration notesContainer() => BoxDecoration(
    color: ColorsManager.mediumGray.withOpacity(0.4),
    borderRadius: BorderRadius.circular(12.r),
  );

  /// Bookmark Hadith card container.
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

  /// Gradient pill for labels.
  static BoxDecoration pill(List<Color> colors) => BoxDecoration(
    gradient: LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(16.r),
  );

  /// Dialog header icon circle gradient.
  static BoxDecoration iconCircleGradient() => BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(
      colors: [ColorsManager.primaryPurple, ColorsManager.secondaryPurple],
    ),
  );

  /// Outlined button-like container used for create-new collection.
  static BoxDecoration outlinedButtonContainer() => BoxDecoration(
    border: Border.all(
      color: ColorsManager.primaryPurple.withOpacity(0.3),
      width: 1.5,
    ),
    borderRadius: BorderRadius.circular(12.r),
    color: Colors.transparent,
  );
}
