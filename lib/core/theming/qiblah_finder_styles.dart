import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';

/// Qiblah Finder feature text styles
/// Extracted from qiblah_finder_screen for consistent styling
class QiblahFinderTextStyles {
  // ==================== COMPASS CARD ====================

  /// Compass card title
  static TextStyle compassCardTitle = TextStyles.titleLarge.copyWith(
    fontWeight: FontWeight.w700,
  );

  /// Loading/waiting message
  static TextStyle loadingMessage = TextStyles.bodyMedium.copyWith(
    color: ColorsManager.secondaryText,
  );

  // ==================== TIPS SECTION ====================

  /// Tips section title
  static TextStyle tipsSectionTitle = TextStyles.titleSmall.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.w800,
  );

  /// Individual tip text
  static TextStyle tipText = TextStyles.bodyMedium.copyWith(
    color: ColorsManager.secondaryText,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  // ==================== INFO CHIPS ====================

  /// Info chip label (e.g., "زاوية القبلة")
  static TextStyle infoChipLabel = TextStyles.bodySmall.copyWith(
    color: ColorsManager.secondaryText,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );

  /// Info chip value (e.g., "45.5°")
  static TextStyle infoChipValue = TextStyles.titleMedium.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.w900,
  );

  // ==================== QIBLAH DIAL ====================

  /// Qiblah badge text ("القبلة")
  static TextStyle qiblahBadgeText = TextStyles.bodyMedium.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.w800,
  );

  /// Qiblah degree badge
  static TextStyle qiblahDegreeBadge = TextStyles.bodySmall.copyWith(
    color: ColorsManager.primaryPurple,
    fontWeight: FontWeight.w900,
  );

  /// Offset label text
  static TextStyle offsetLabel = TextStyles.bodySmall.copyWith(
    color: ColorsManager.secondaryText,
    fontWeight: FontWeight.w700,
  );

  // ==================== MESSAGE CARD ====================

  /// Message card title (error/permission messages)
  static TextStyle messageCardTitle = TextStyles.titleLarge.copyWith(
    fontWeight: FontWeight.w800,
  );

  /// Message card description
  static TextStyle messageCardDescription = TextStyles.bodyMedium.copyWith(
    color: ColorsManager.secondaryText,
  );

  /// Message card button text
  static TextStyle messageCardButtonText = TextStyles.labelLarge.copyWith(
    color: ColorsManager.white,
    fontWeight: FontWeight.w700,
  );
}
