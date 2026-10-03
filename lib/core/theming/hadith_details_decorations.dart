import 'package:mishkat_almasabih/core/theming/decorations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class HadithDetailsDecorations {
  static BoxDecoration contentCard() => Decorations.readingCard();

  static BoxDecoration labelChip() =>
      Decorations.softChip(ColorsManager.primaryPurple);

  static BoxDecoration actionIcon(Color color) => Decorations.iconWell(color);

  static BoxDecoration sectionCard() => Decorations.card(radius: 16);

  static BoxDecoration actionRow() => BoxDecoration(
    borderRadius: BorderRadius.circular(12.r),
    color: ColorsManager.primarySoft,
  );

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

  static BoxDecoration headerInfo() => BoxDecoration(
    color: ColorsManager.primarySoft,
    borderRadius: BorderRadius.circular(16.r),
  );

  static Color circleActionAvatarBg() => ColorsManager.primarySoft;

  static Color gradeChipBg(Color base) => base.withValues(alpha: 0.12);
}
