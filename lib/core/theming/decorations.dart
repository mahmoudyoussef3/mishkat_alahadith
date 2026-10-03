import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'colors.dart';

class Decorations {
  Decorations._();

  static LinearGradient get primaryDiagonalGradient => LinearGradient(
    colors: [ColorsManager.headerStart, ColorsManager.headerEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Soft elevation for cards. Dark mode relies on borders and surface
  /// tones instead, because shadows on near-black backgrounds read as smudges.
  static List<BoxShadow> get cardShadow =>
      ColorsManager.isDark
          ? const []
          : [
            BoxShadow(
              color: ColorsManager.shadow,
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ];

  /// The standard content card: soft surface, hairline border, soft shadow.
  static BoxDecoration card({double radius = 20}) => BoxDecoration(
    color: ColorsManager.cardBackground,
    borderRadius: BorderRadius.circular(radius.r),
    border: Border.all(color: ColorsManager.mediumGray),
    boxShadow: cardShadow,
  );

  static BoxDecoration get infoCard => card(radius: 16);

  /// Surface for long-form reading (hadith text). A neutral paper card:
  /// colour stays out of the way of the words.
  static BoxDecoration readingCard() => card(radius: 24);

  /// Secondary content panel (explanations, word meanings, lessons).
  static BoxDecoration contentPanel() => BoxDecoration(
    color: ColorsManager.cardBackground,
    borderRadius: BorderRadius.circular(18.r),
    border: Border.all(color: ColorsManager.mediumGray),
  );

  /// Track that holds a row of [tabPill]s.
  static BoxDecoration tabsTrack() => BoxDecoration(
    color: ColorsManager.lightGray,
    borderRadius: BorderRadius.circular(18.r),
  );

  static BoxDecoration tabPill({required bool isSelected}) => BoxDecoration(
    color: isSelected ? ColorsManager.primaryPurple : Colors.transparent,
    borderRadius: BorderRadius.circular(14.r),
  );

  /// Tinted square that holds an icon in [color].
  static BoxDecoration iconWell(Color color, {double radius = 12}) =>
      BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(radius.r),
      );

  /// Small tinted label; pair with text in [color].
  static BoxDecoration softChip(Color color) => BoxDecoration(
    color: color.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(20.r),
  );

  static BoxDecoration get circleWhiteShadow => BoxDecoration(
    shape: BoxShape.circle,
    color: ColorsManager.white,
    boxShadow: [
      BoxShadow(
        color: ColorsManager.black.withOpacity(0.2),
        blurRadius: 30,
        spreadRadius: 5,
        offset: const Offset(0, 15),
      ),
    ],
  );

  static BorderRadius verticalTop(double radius) =>
      BorderRadius.vertical(top: Radius.circular(radius));
}
