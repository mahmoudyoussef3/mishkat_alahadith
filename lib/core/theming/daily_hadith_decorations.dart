import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class DailyHadithDecorations {
  // Card containing the hadith content
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

  // The small label chip at top of hadith card (e.g., "نص الحديث")
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

  // Decorative corner container with quote icon
  static BoxDecoration cornerQuote() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withOpacity(0.1),
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(20.r),
        bottomLeft: Radius.circular(20.r),
      ),
    );
  }

  // Small action icon (copy/share) decoration
  static BoxDecoration actionIcon(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: color.withOpacity(0.2)),
    );
  }

  // Container holding tabs section
  static BoxDecoration tabsContainer() {
    return BoxDecoration(
      color: ColorsManager.white,
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

  // Tab pill decoration depending on selection state
  static BoxDecoration tabPill({required bool isSelected}) {
    return BoxDecoration(
      color: isSelected ? ColorsManager.primaryPurple : ColorsManager.white,
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

  // Outer container for selected tab content
  static BoxDecoration tabContentContainer() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: ColorsManager.gray),
    );
  }

  // Actions row container behind copy/share/save
  static BoxDecoration actionRow() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12.r),
      color: ColorsManager.primaryPurple.withOpacity(0.1),
    );
  }

  // Circle avatar background for action icons
  static Color circleActionAvatarBg() {
    return ColorsManager.primaryPurple.withOpacity(0.1);
  }

  // Grade chip background for attribution/grade widget
  static Color gradeChipBg(Color base) {
    return base.withOpacity(0.1);
  }
}
