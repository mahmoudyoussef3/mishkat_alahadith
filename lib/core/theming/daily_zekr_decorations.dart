import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

class DailyZekrDecorations {
  // Info card containing how it works
  static BoxDecoration infoCard() => BoxDecoration(
    color: ColorsManager.primaryGold.withOpacity(0.08),
    borderRadius: BorderRadius.circular(12.r),
    border: Border.all(
      color: ColorsManager.primaryGold.withOpacity(0.4),
      width: 1,
    ),
  );

  // Square icon tile inside the info card
  static BoxDecoration infoIconTile() => BoxDecoration(
    color: ColorsManager.primaryGold.withOpacity(0.2),
    borderRadius: BorderRadius.circular(10.r),
  );

  // Divider gradient between sections
  static BoxDecoration dividerGradient() => BoxDecoration(
    gradient: LinearGradient(
      colors: [
        ColorsManager.primaryPurple.withOpacity(0.3),
        ColorsManager.primaryGold.withOpacity(0.6),
        ColorsManager.primaryPurple.withOpacity(0.3),
      ],
    ),
    borderRadius: BorderRadius.circular(1.r),
  );

  // Zekr card container decoration based on enabled/checked state
  static BoxDecoration zekrCard({
    required bool enabled,
    required bool checked,
  }) {
    final bgColor =
        checked
            ? ColorsManager.primaryPurple.withOpacity(0.06)
            : ColorsManager.cardBackground;
    final borderColor =
        checked ? ColorsManager.primaryPurple : ColorsManager.mediumGray;
    return BoxDecoration(
      color: enabled ? bgColor : ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: borderColor, width: checked ? 1.8 : 1.2),
      boxShadow: [
        BoxShadow(
          color: ColorsManager.primaryPurple.withOpacity(checked ? 0.10 : 0.06),
          blurRadius: checked ? 10 : 7,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // Leading small icon container inside Zekr card
  static BoxDecoration leadingIconTile() => BoxDecoration(
    color: ColorsManager.primaryPurple.withOpacity(0.10),
    borderRadius: BorderRadius.circular(8.r),
    border: Border.all(
      color: ColorsManager.primaryPurple.withOpacity(0.25),
      width: 1,
    ),
  );

  // Footer pill decoration inside Zekr card
  static BoxDecoration footerPill({
    required bool enabled,
    required bool checked,
  }) {
    final Color bg =
        !enabled
            ? ColorsManager.mediumGray.withOpacity(0.08)
            : checked
            ? ColorsManager.hadithAuthentic.withOpacity(0.12)
            : ColorsManager.primaryGold.withOpacity(0.10);
    final Color border =
        !enabled
            ? ColorsManager.mediumGray.withOpacity(0.35)
            : checked
            ? ColorsManager.hadithAuthentic.withOpacity(0.6)
            : ColorsManager.primaryGold.withOpacity(0.6);
    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: border, width: 1),
    );
  }

  // Right side vertical gradient bar in Zekr card
  static BoxDecoration rightGradientBar() => BoxDecoration(
    borderRadius: BorderRadius.circular(2.r),
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [ColorsManager.primaryPurple, ColorsManager.primaryGold],
    ),
  );

  // Personal tasks section container
  static BoxDecoration personalTasksSection() => BoxDecoration(
    color: ColorsManager.cardBackground,
    borderRadius: BorderRadius.circular(14.r),
    border: Border.all(
      color: ColorsManager.primaryGold.withOpacity(0.35),
      width: 1,
    ),
  );

  // Single personal task tile
  static BoxDecoration personalTaskTile({required bool isDone}) =>
      BoxDecoration(
        color:
            isDone
                ? ColorsManager.primaryPurple.withOpacity(0.06)
                : ColorsManager.secondaryBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color:
              isDone
                  ? ColorsManager.primaryPurple.withOpacity(0.65)
                  : ColorsManager.mediumGray,
          width: 1,
        ),
      );

  // Bottom sheet shape
  static ShapeBorder bottomSheetShape() => RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
  );

  // TextField borders inside bottom sheet
  static OutlineInputBorder inputBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12.r),
    borderSide: BorderSide(color: color),
  );
}
