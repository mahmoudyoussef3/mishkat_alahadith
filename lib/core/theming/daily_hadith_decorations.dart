import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class DailyHadithDecorations {
  static BoxDecoration contentCard() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          ColorsManager.secondaryBackground,
          ColorsManager.primaryPurple.withOpacity(0.2),
        ],
      ),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(
        color: ColorsManager.primaryPurple.withOpacity(0.15),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: ColorsManager.primaryPurple.withOpacity(0.08),
          blurRadius: 20.r,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration labelChip() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(
        color: ColorsManager.primaryPurple.withOpacity(0.2),
        width: 1,
      ),
    );
  }

  static BoxDecoration cornerQuote() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withOpacity(0.1),
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(20.r),
        bottomLeft: Radius.circular(20.r),
      ),
    );
  }

  static BoxDecoration actionIcon(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: color.withOpacity(0.2)),
    );
  }

  static BoxDecoration tabsContainer() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: ColorsManager.primaryPurple.withOpacity(0.08),
          blurRadius: 20.r,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration tabPill({required bool isSelected}) {
    return BoxDecoration(
      color: isSelected ? ColorsManager.primaryPurple : ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(14.r),
      boxShadow:
          isSelected
              ? [
                BoxShadow(
                  color: ColorsManager.primaryPurple.withOpacity(0.3),
                  blurRadius: 10.r,
                  offset: const Offset(0, 4),
                ),
              ]
              : [],
      border: Border.all(
        color:
            isSelected ? ColorsManager.primaryPurple : ColorsManager.lightGray,
        width: 1,
      ),
    );
  }

  static BoxDecoration tabContentContainer() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: ColorsManager.gray),
    );
  }

  static BoxDecoration actionRow() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12.r),
      color: ColorsManager.primaryPurple.withOpacity(0.1),
    );
  }

  static Color circleActionAvatarBg() {
    return ColorsManager.primaryPurple.withOpacity(0.1);
  }

  static Color gradeChipBg(Color base) {
    return base.withOpacity(0.1);
  }
}
