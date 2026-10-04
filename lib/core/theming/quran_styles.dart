import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/styles.dart';
import 'package:mushaf_text/mushaf_text.dart';

class QuranTextStyles {
  static const String _decorativeFont = 'Amiri';
  static const String _mushafFontPackage = 'mushaf_text';

  /// Quran text in the bundled King Fahd Complex face.
  static TextStyle mushafText({required Color color, required double size}) {
    return TextStyle(
      fontFamily: mushafFontFamily,
      package: _mushafFontPackage,
      fontSize: size,
      color: color,
      height: 1.9,
    );
  }

  // ── hub ────────────────────────────────────────────────────────────────

  static TextStyle get continueReadingLabel => TextStyles.bodySmall.copyWith(
    color: ColorsManager.white.withValues(alpha: 0.85),
    fontWeight: FontWeight.w600,
  );

  static TextStyle get continueReadingTitle => TextStyle(
    fontFamily: _decorativeFont,
    fontSize: 22.sp,
    fontWeight: FontWeight.w700,
    color: ColorsManager.white,
    height: 1.4,
  );

  static TextStyle get continueReadingMeta => TextStyles.bodySmall.copyWith(
    color: ColorsManager.white.withValues(alpha: 0.85),
  );

  /// No color: the label takes the foreground from
  /// [QuranDecorations.continueReadingButton], which differs per theme.
  static TextStyle get continueReadingButton =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800);

  static TextStyle get entryCardTitle => TextStyle(
    fontFamily: _decorativeFont,
    fontSize: 19.sp,
    fontWeight: FontWeight.w700,
    color: ColorsManager.primaryText,
  );

  static TextStyle get entryCardSubtitle => TextStyles.bodySmall.copyWith(
    color: ColorsManager.secondaryText,
    height: 1.4,
  );

  // ── index ──────────────────────────────────────────────────────────────

  static TextStyle tabLabel(Color color, {required bool selected}) => TextStyle(
    fontSize: 13.sp,
    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
    color: color,
  );

  static TextStyle surahName(Color color) => TextStyle(
    fontFamily: _decorativeFont,
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    color: color,
    height: 1.3,
  );

  static TextStyle tileTitle(Color color) =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: color);

  static TextStyle tileMeta(Color color) =>
      TextStyle(fontSize: 11.5.sp, color: color, height: 1.4);

  static TextStyle tileTrailing(Color color) =>
      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: color);

  static TextStyle numberBadge(Color color) =>
      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: color);

  static TextStyle filterField(Color color) =>
      TextStyle(fontSize: 14.sp, color: color);

  static TextStyle sectionTitle(Color color) =>
      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: color);

  static TextStyle sectionHint(Color color) =>
      TextStyle(fontSize: 12.sp, color: color, height: 1.6);

  static TextStyle message(Color color) => TextStyle(
    fontSize: 14.sp,
    color: color,
    height: 1.6,
    fontWeight: FontWeight.w600,
  );

  // ── reader ─────────────────────────────────────────────────────────────

  static TextStyle readerTitle(MushafColors colors) => TextStyle(
    fontFamily: _decorativeFont,
    fontSize: 18.sp,
    fontWeight: FontWeight.w700,
    color: colors.ink,
    height: 1.3,
  );

  static TextStyle readerSubtitle(MushafColors colors) => TextStyle(
    fontSize: 11.5.sp,
    fontWeight: FontWeight.w600,
    color: colors.accent,
  );

  static TextStyle pageChip(MushafColors colors) => TextStyle(
    fontSize: 13.sp,
    fontWeight: FontWeight.w800,
    color: colors.accent,
  );

  static TextStyle sliderLabel(MushafColors colors) => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w700,
    color: colors.paper,
  );

  static TextStyle focusRule(Color color) =>
      TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: color);

  static TextStyle focusCounter(MushafColors colors) =>
      TextStyle(fontSize: 12.5.sp, color: colors.accent);

  // ── sheets ─────────────────────────────────────────────────────────────

  static TextStyle sheetTitle(Color color) => TextStyle(
    fontFamily: _decorativeFont,
    fontSize: 20.sp,
    fontWeight: FontWeight.w700,
    color: color,
    height: 1.3,
  );

  static TextStyle ruleTitle(Color color) =>
      TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: color);

  static TextStyle ruleFamily(Color color) =>
      TextStyle(fontSize: 12.5.sp, color: color);

  static TextStyle detailLabel(Color color) =>
      TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700, color: color);

  static TextStyle detailValue(Color color) =>
      TextStyle(fontSize: 14.5.sp, height: 1.75, color: color);

  static TextStyle evidence(Color color) => TextStyle(
    fontFamily: _decorativeFont,
    fontSize: 15.sp,
    height: 2.0,
    color: color,
  );

  static TextStyle chip(Color color) =>
      TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700, color: color);

  static TextStyle actionLabel(Color color) =>
      TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: color);

  static TextStyle switchTitle(Color color) =>
      TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.w700, color: color);

  static TextStyle switchSubtitle(Color color) =>
      TextStyle(fontSize: 12.sp, color: color, height: 1.5);

  static TextStyle themeOptionLabel(Color color, {required bool selected}) =>
      TextStyle(
        fontSize: 12.5.sp,
        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
        color: color,
      );

  // ── search ─────────────────────────────────────────────────────────────

  static TextStyle get searchField => TextStyles.bodyLarge.copyWith(
    color: ColorsManager.white,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get searchHint => TextStyles.bodyMedium.copyWith(
    color: ColorsManager.white.withValues(alpha: 0.7),
  );

  static TextStyle get searchSummary => TextStyles.bodyMedium.copyWith(
    color: ColorsManager.secondaryText,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get searchHitReference => TextStyles.bodySmall.copyWith(
    color: ColorsManager.purpleText,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get searchHitPage => TextStyles.bodySmall.copyWith(
    color: ColorsManager.secondaryText,
    fontWeight: FontWeight.w600,
  );

  // ── tajweed guide ──────────────────────────────────────────────────────

  static TextStyle get guideIntro => TextStyles.bodyMedium.copyWith(
    color: ColorsManager.primaryText,
    height: 1.8,
  );

  static TextStyle get guideFamilyTitle => TextStyles.titleMedium.copyWith(
    color: ColorsManager.primaryText,
    fontWeight: FontWeight.w800,
  );

  static TextStyle get guideFamilySubtitle =>
      TextStyles.bodySmall.copyWith(color: ColorsManager.secondaryText);

  static TextStyle get guideNote => TextStyles.bodySmall.copyWith(
    color: ColorsManager.primaryText,
    height: 1.8,
  );
}
