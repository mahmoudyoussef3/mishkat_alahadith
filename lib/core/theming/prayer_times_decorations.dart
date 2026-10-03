import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class PrayerTimesDecorations {
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

  static BoxDecoration nextPrayerContainer() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: ColorsManager.mediumGray, width: 1),
    );
  }

  static BoxDecoration countdownPill() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12.r),
    );
  }

  static BoxDecoration gridRowContainer() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: ColorsManager.mediumGray, width: 1),
    );
  }

  static BoxDecoration gridRowIconBg() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withOpacity(0.12),
      borderRadius: BorderRadius.circular(10.r),
    );
  }
}
