import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class HadithDetailsDecorations {
  // Main hadith text card container
  static BoxDecoration contentCard() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          ColorsManager.secondaryBackground,
          ColorsManager.primaryPurple.withOpacity(0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(24.r),
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

  // Chip label at top of hadith card ("نص الحديث")
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

  // Small action icon decoration
  static BoxDecoration actionIcon(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: color.withOpacity(0.2)),
    );
  }

  // Generic section card container decoration
  static BoxDecoration sectionCard() {
    return BoxDecoration(
      color: ColorsManager.white,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Purple-tinted container used for actions / navigation rows
  static BoxDecoration actionRow() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12.r),
      color: ColorsManager.primaryPurple.withOpacity(0.1),
    );
  }

  // Islamic separator gradient decoration
  static BoxDecoration separator() {
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

  // Header info container (green accent)
  static BoxDecoration headerInfo() {
    return BoxDecoration(
      color: ColorsManager.primaryGreen.withOpacity(0.05),
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: ColorsManager.primaryGreen.withOpacity(0.2)),
    );
  }

  // Circle avatar background for action icons
  static Color circleActionAvatarBg() {
    return ColorsManager.primaryPurple.withOpacity(0.1);
  }

  // Grade chip background color with opacity
  static Color gradeChipBg(Color base) {
    return base.withOpacity(0.1);
  }
}
