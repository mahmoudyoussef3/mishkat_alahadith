import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class HomeDecorations {
  static BoxDecoration appBarGradientOverlay() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ColorsManager.primaryPurple.withOpacity(0.3),
          ColorsManager.primaryPurple,
        ],
      ),
    );
  }

  static BoxDecoration appBarIconButtonBorder() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
    );
  }

  static Color appBarIconButtonBg() {
    return Colors.white.withOpacity(0.15);
  }

  static BoxDecoration sectionDivider() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          ColorsManager.primaryPurple.withOpacity(0.3),
          ColorsManager.primaryGold.withOpacity(0.6),
          ColorsManager.primaryPurple.withOpacity(0.3),
        ],
      ),
      borderRadius: BorderRadius.circular(1.r),
    );
  }

  static BoxDecoration readButton() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: Colors.white70),
    );
  }

  static BoxDecoration dailyHadithCornerQuote() {
    return BoxDecoration(
      color: ColorsManager.primaryGreen.withOpacity(0.1),
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(24.r),
        bottomLeft: Radius.circular(24.r),
      ),
    );
  }

  static BoxDecoration categoryCard() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: ColorsManager.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration categoryIconContainer(Color color) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color.withOpacity(0.2), color.withOpacity(0.1)],
      ),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: color.withOpacity(0.3), width: 1),
    );
  }

  static BoxDecoration categoryIndicatorBar(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.6),
      borderRadius: BorderRadius.circular(2),
    );
  }

  static BoxDecoration mainCategoryCorner() {
    return BoxDecoration(
      color: ColorsManager.white.withOpacity(0.15),
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(24),
        bottomLeft: Radius.circular(24),
      ),
    );
  }

  static BoxDecoration mainCategoryCountPill() {
    return BoxDecoration(
      color: ColorsManager.white.withOpacity(0.25),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(
        color: ColorsManager.white.withOpacity(0.4),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8.r,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration mainCategoryIconOverlay() {
    return BoxDecoration(
      color: ColorsManager.white.withOpacity(0.2),
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: ColorsManager.white.withOpacity(0.3), width: 1),
    );
  }

  static BoxDecoration get featuredHeaderGradient => BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [ColorsManager.primaryPurple, ColorsManager.secondaryPurple],
    ),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
    ),
  );

  static BoxDecoration featuredFooter() {
    return BoxDecoration(
      color: ColorsManager.lightGray,
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  static BoxDecoration quickActionCard() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: ColorsManager.primaryPurple.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration quickActionIconBg(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  static BoxDecoration searchOuter() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  static BoxDecoration shimmerCardContainer() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: ColorsManager.primaryPurple.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration shimmerBox({bool circle = false, double? radius}) {
    return BoxDecoration(
      color: ColorsManager.mediumGray,
      borderRadius:
          circle
              ? BorderRadius.circular(50)
              : BorderRadius.circular(radius ?? 8.r),
    );
  }

  static BoxDecoration statsCard(Color baseColor) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          baseColor.withOpacity(0.95),
          ColorsManager.primaryPurple.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: [
        BoxShadow(
          color: baseColor.withOpacity(0.25),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
