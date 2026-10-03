import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

class QiblahFinderDecorations {
  static BoxDecoration compassCard() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: ColorsManager.mediumGray, width: 1),
      boxShadow: [
        BoxShadow(
          color: ColorsManager.mediumGray.withOpacity(0.18),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static BoxDecoration tipsContainer() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withOpacity(0.06),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(
        color: ColorsManager.primaryPurple.withOpacity(0.18),
        width: 1,
      ),
    );
  }

  static BoxDecoration tipsIconContainer() {
    return BoxDecoration(
      color: ColorsManager.primaryGold.withOpacity(0.14),
      borderRadius: BorderRadius.circular(10.r),
    );
  }

  static const IconData tipsIcon = Icons.tips_and_updates_rounded;
  static Color get tipsIconColor => ColorsManager.primaryGold;

  static const IconData tipsCheckIcon = Icons.check_circle_rounded;
  static Color get tipsCheckIconColor => ColorsManager.primaryPurple;

  static BoxDecoration infoChip() {
    return BoxDecoration(
      color: ColorsManager.secondaryBackground,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: ColorsManager.mediumGray, width: 1),
    );
  }

  static Color get infoChipIconColor => ColorsManager.primaryPurple;

  static BoxDecoration dialOuterRing() {
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ColorsManager.primaryPurple.withOpacity(0.22),
          ColorsManager.primaryPurple.withOpacity(0.10),
        ],
      ),
    );
  }

  static BoxDecoration dialInnerSurface() {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: ColorsManager.cardBackground,
      border: Border.all(color: ColorsManager.mediumGray, width: 1),
      boxShadow: [
        BoxShadow(
          color: ColorsManager.mediumGray.withOpacity(0.22),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration dialCenterHub() {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: ColorsManager.primaryPurple,
      border: Border.all(color: ColorsManager.white, width: 2),
    );
  }

  static BoxDecoration qiblahBadgeContainer() {
    return BoxDecoration(
      color: ColorsManager.secondaryBackground,
      borderRadius: BorderRadius.circular(999.r),
      border: Border.all(color: ColorsManager.mediumGray, width: 1),
      boxShadow: [
        BoxShadow(
          color: ColorsManager.mediumGray.withOpacity(0.16),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration qiblahIconContainer() {
    return BoxDecoration(
      color: ColorsManager.primaryGold.withOpacity(0.14),
      shape: BoxShape.circle,
    );
  }

  static const IconData qiblahIcon = Icons.mosque;
  static Color get qiblahIconColor => ColorsManager.primaryGold;

  static BoxDecoration qiblahDegreeBadge() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withOpacity(0.08),
      borderRadius: BorderRadius.circular(999.r),
      border: Border.all(
        color: ColorsManager.primaryPurple.withOpacity(0.16),
        width: 1,
      ),
    );
  }

  static BoxDecoration offsetLabelContainer() {
    return BoxDecoration(
      color: ColorsManager.secondaryBackground,
      borderRadius: BorderRadius.circular(999.r),
      border: Border.all(color: ColorsManager.mediumGray, width: 1),
    );
  }

  static Paint dialRingPaint(double radius) {
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.06
      ..color = ColorsManager.primaryPurple.withOpacity(0.18);
  }

  static Paint dialMinorTickPaint(double radius) {
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.012
      ..strokeCap = StrokeCap.round
      ..color = ColorsManager.mediumGray.withOpacity(0.75);
  }

  static Paint dialMajorTickPaint(double radius) {
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.02
      ..strokeCap = StrokeCap.round
      ..color = ColorsManager.primaryPurple.withOpacity(0.55);
  }

  static Color get dialNorthLabelColor => ColorsManager.primaryPurple;
  static Color get dialOtherLabelColor => ColorsManager.secondaryText;

  static Paint needlePaint() {
    return Paint()
      ..style = PaintingStyle.fill
      ..color = ColorsManager.primaryGold;
  }

  static Paint needleShadowPaint() {
    return Paint()
      ..style = PaintingStyle.fill
      ..color = ColorsManager.black.withOpacity(0.10);
  }

  static BoxDecoration messageCard() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: ColorsManager.mediumGray, width: 1),
    );
  }

  static ButtonStyle messageCardButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: ColorsManager.primaryPurple,
      foregroundColor: ColorsManager.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    );
  }
}
