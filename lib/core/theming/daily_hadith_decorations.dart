import 'package:mishkat_almasabih/core/theming/decorations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class DailyHadithDecorations {
  static BoxDecoration contentCard() => Decorations.readingCard();

  static BoxDecoration labelChip() =>
      Decorations.softChip(ColorsManager.primaryPurple);

  static BoxDecoration cornerQuote() => BoxDecoration(
    color: ColorsManager.primarySoft,
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(24.r),
      bottomLeft: Radius.circular(20.r),
    ),
  );

  static BoxDecoration actionIcon(Color color) => Decorations.iconWell(color);

  static BoxDecoration tabsContainer() => Decorations.tabsTrack();

  static BoxDecoration tabPill({required bool isSelected}) =>
      Decorations.tabPill(isSelected: isSelected);

  static BoxDecoration tabContentContainer() => Decorations.contentPanel();

  static BoxDecoration actionRow() => BoxDecoration(
    borderRadius: BorderRadius.circular(12.r),
    color: ColorsManager.primarySoft,
  );

  static Color circleActionAvatarBg() => ColorsManager.primarySoft;

  static Color gradeChipBg(Color base) => base.withValues(alpha: 0.12);
}
