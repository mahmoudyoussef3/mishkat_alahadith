import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class LibraryDecorations {
  static Color get scaffoldBackground => ColorsManager.secondaryBackground;

  static Color get libraryScreenBackground => ColorsManager.primaryBackground;

  static BoxDecoration bookCardContainer() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(20.r),
    );
  }

  static BoxDecoration bookImageBox(String assetPath) {
    return BoxDecoration(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      image: DecorationImage(image: AssetImage(assetPath), fit: BoxFit.cover),
    );
  }

  static BoxDecoration shimmerCard() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
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

  static BoxDecoration shimmerBox({bool circular = false, double? radius}) {
    return BoxDecoration(
      color: ColorsManager.mediumGray,
      borderRadius:
          circular
              ? BorderRadius.circular(50)
              : BorderRadius.circular(radius ?? 8.r),
    );
  }

  static BoxDecoration sectionHeaderContainer() {
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

  static BoxDecoration sectionHeaderIconContainer(Color backgroundColor) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  static Color get booksColor =>
      ColorsManager.isDark
          ? ColorsManager.darkPurpleText
          : const Color.fromARGB(255, 51, 13, 128);

  static Color get chaptersColor => ColorsManager.hadithAuthentic;

  static Color get hadithsColor => ColorsManager.primaryGold;

  static LinearGradient kutubTisaaGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [ColorsManager.headerStart, ColorsManager.headerEnd],
    );
  }

  static LinearGradient arbaainGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [ColorsManager.headerStart, ColorsManager.headerEnd],
    );
  }

  static LinearGradient adabGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [ColorsManager.headerStart, ColorsManager.headerEnd],
    );
  }

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
