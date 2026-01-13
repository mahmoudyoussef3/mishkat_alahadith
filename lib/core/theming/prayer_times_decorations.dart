import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class PrayerTimesDecorations {
  // Section divider gradient
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

  // Next prayer card container
  static BoxDecoration nextPrayerContainer() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: ColorsManager.mediumGray, width: 1),
    );
  }

  // Countdown pill decoration
  static BoxDecoration countdownPill() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  // Prayer grid row container
  static BoxDecoration gridRowContainer() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: ColorsManager.mediumGray, width: 1),
    );
  }

  // Prayer grid icon background
  static BoxDecoration gridRowIconBg() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withOpacity(0.12),
      borderRadius: BorderRadius.circular(10.r),
    );
  }
}
