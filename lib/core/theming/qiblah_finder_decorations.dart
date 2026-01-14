import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';

/// Qiblah Finder feature decorations
/// Extracted from qiblah_finder_screen for consistent styling
class QiblahFinderDecorations {
  // ==================== COMPASS CARD ====================

  /// Main compass card container
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

  // ==================== TIPS SECTION ====================

  /// Tips container background
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

  /// Tips icon container
  static BoxDecoration tipsIconContainer() {
    return BoxDecoration(
      color: ColorsManager.primaryGold.withOpacity(0.14),
      borderRadius: BorderRadius.circular(10.r),
    );
  }

  /// Tips icon
  static const IconData tipsIcon = Icons.tips_and_updates_rounded;
  static const Color tipsIconColor = ColorsManager.primaryGold;

  /// Tips check icon
  static const IconData tipsCheckIcon = Icons.check_circle_rounded;
  static Color tipsCheckIconColor = ColorsManager.primaryPurple;

  // ==================== INFO CHIPS ====================

  /// Info chip container
  static BoxDecoration infoChip() {
    return BoxDecoration(
      color: ColorsManager.secondaryBackground,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: ColorsManager.mediumGray, width: 1),
    );
  }

  /// Info chip icon color
  static const Color infoChipIconColor = ColorsManager.primaryPurple;

  // ==================== QIBLAH DIAL ====================

  /// Outer ring gradient
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

  /// Inner dial surface
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

  /// Center hub
  static BoxDecoration dialCenterHub() {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: ColorsManager.primaryPurple,
      border: Border.all(color: ColorsManager.white, width: 2),
    );
  }

  /// Qiblah badge container
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

  /// Qiblah icon container (mosque icon)
  static BoxDecoration qiblahIconContainer() {
    return BoxDecoration(
      color: ColorsManager.primaryGold.withOpacity(0.14),
      shape: BoxShape.circle,
    );
  }

  /// Qiblah icon
  static const IconData qiblahIcon = Icons.mosque;
  static const Color qiblahIconColor = ColorsManager.primaryGold;

  /// Qiblah degree badge
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

  /// Offset label container
  static BoxDecoration offsetLabelContainer() {
    return BoxDecoration(
      color: ColorsManager.secondaryBackground,
      borderRadius: BorderRadius.circular(999.r),
      border: Border.all(color: ColorsManager.mediumGray, width: 1),
    );
  }

  // ==================== COMPASS DIAL PAINTING ====================

  /// Compass ring paint properties
  static Paint dialRingPaint(double radius) {
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.06
      ..color = ColorsManager.primaryPurple.withOpacity(0.18);
  }

  /// Minor tick paint
  static Paint dialMinorTickPaint(double radius) {
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.012
      ..strokeCap = StrokeCap.round
      ..color = ColorsManager.mediumGray.withOpacity(0.75);
  }

  /// Major tick paint
  static Paint dialMajorTickPaint(double radius) {
    return Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.02
      ..strokeCap = StrokeCap.round
      ..color = ColorsManager.primaryPurple.withOpacity(0.55);
  }

  /// Cardinal label colors
  static const Color dialNorthLabelColor = ColorsManager.primaryPurple;
  static const Color dialOtherLabelColor = ColorsManager.secondaryText;

  // ==================== NEEDLE PAINTING ====================

  /// Needle paint (Qiblah direction arrow)
  static Paint needlePaint() {
    return Paint()
      ..style = PaintingStyle.fill
      ..color = ColorsManager.primaryGold;
  }

  /// Needle shadow paint
  static Paint needleShadowPaint() {
    return Paint()
      ..style = PaintingStyle.fill
      ..color = ColorsManager.black.withOpacity(0.10);
  }

  // ==================== MESSAGE CARD ====================

  /// Message card (error/permission states)
  static BoxDecoration messageCard() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: ColorsManager.mediumGray, width: 1),
    );
  }

  /// Message card button style
  static ButtonStyle messageCardButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: ColorsManager.primaryPurple,
      foregroundColor: ColorsManager.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    );
  }
}
