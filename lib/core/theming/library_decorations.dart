import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class LibraryDecorations {
  // ==================== SCAFFOLD ====================

  // Scaffold background color
  static const Color scaffoldBackground = ColorsManager.secondaryBackground;

  // Library screen background
  static const Color libraryScreenBackground = ColorsManager.primaryBackground;

  // ==================== BOOK CARD ====================

  // Book card outer container
  static BoxDecoration bookCardContainer() {
    return BoxDecoration(
      color: ColorsManager.white,
      borderRadius: BorderRadius.circular(20.r),
    );
  }

  // Book image box with rounded top corners
  static BoxDecoration bookImageBox(String assetPath) {
    return BoxDecoration(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      image: DecorationImage(image: AssetImage(assetPath), fit: BoxFit.cover),
    );
  }

  // ==================== SHIMMER ====================

  // Shimmer card container used in grid placeholders
  static BoxDecoration shimmerCard() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8.r,
          offset: Offset(0, 4.h),
        ),
      ],
    );
  }

  // Generic shimmer box for inner lines/rects
  static BoxDecoration shimmerBox({bool circular = false, double? radius}) {
    return BoxDecoration(
      color: Colors.grey[300],
      borderRadius:
          circular
              ? BorderRadius.circular(50)
              : BorderRadius.circular(radius ?? 8.r),
    );
  }

  // ==================== LIBRARY BOOKS SCREEN ====================

  // Section header container (for statistics and categories)
  static BoxDecoration sectionHeaderContainer() {
    return BoxDecoration(
      color: ColorsManager.white,
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

  // Icon container for section headers
  static BoxDecoration sectionHeaderIconContainer(Color backgroundColor) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  // Statistics card color for books
  static const Color booksColor = Color.fromARGB(255, 51, 13, 128);

  // Statistics card color for chapters
  static const Color chaptersColor = ColorsManager.hadithAuthentic;

  // Statistics card color for hadiths
  static const Color hadithsColor = ColorsManager.primaryGold;

  // Category card gradient for Kutub Tisaa
  static LinearGradient kutubTisaaGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [ColorsManager.primaryGreen, ColorsManager.darkPurple],
    );
  }

  // Category card gradient for Arbaain
  static LinearGradient arbaainGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [ColorsManager.primaryGreen, ColorsManager.darkPurple],
    );
  }

  // Category card gradient for Adab
  static LinearGradient adabGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [ColorsManager.primaryGreen, ColorsManager.darkPurple],
    );
  }

  // Islamic separator decoration
  static BoxDecoration islamicSeparator() {
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
}
