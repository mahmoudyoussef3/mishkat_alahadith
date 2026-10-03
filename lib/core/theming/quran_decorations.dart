import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mushaf_text/mushaf_text.dart';

/// The colours a Quran list or sheet is drawn in.
///
/// The same index, rule and bookmark widgets appear on app screens (in the app
/// palette) and on top of the mushaf page (in its paper and ink), so they take
/// their colours from here rather than from either palette directly.
@immutable
class QuranSurfaceColors {
  final Color background;
  final Color surface;
  final Color title;
  final Color subtitle;
  final Color accent;
  final Color border;
  final Color selection;

  /// Supplies tajweed colours tuned for this background.
  final MushafColors mushaf;

  const QuranSurfaceColors({
    required this.background,
    required this.surface,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.border,
    required this.selection,
    required this.mushaf,
  });

  factory QuranSurfaceColors.app() => QuranSurfaceColors(
    background: ColorsManager.secondaryBackground,
    surface: ColorsManager.cardBackground,
    title: ColorsManager.primaryText,
    subtitle: ColorsManager.secondaryText,
    accent: ColorsManager.primaryPurple,
    border: ColorsManager.mediumGray,
    selection: ColorsManager.primaryPurple.withValues(alpha: 0.10),
    mushaf: ColorsManager.isDark ? MushafColors.dark : MushafColors.light,
  );

  factory QuranSurfaceColors.mushaf(MushafColors colors) => QuranSurfaceColors(
    background: colors.paper,
    surface: colors.banner,
    title: colors.ink,
    subtitle: colors.accent.withValues(alpha: 0.85),
    accent: colors.accent,
    border: colors.gold.withValues(alpha: 0.45),
    selection: colors.highlight,
    mushaf: colors,
  );

  Color ruleColor(TajweedRule rule) => mushaf.tajweedColor(rule);
}

class QuranDecorations {
  // ── hub ────────────────────────────────────────────────────────────────

  static BoxDecoration continueReadingCard() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [ColorsManager.primaryPurple, ColorsManager.darkPurple],
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
      ),
      borderRadius: BorderRadius.circular(20.r),
      boxShadow: [
        BoxShadow(
          color: ColorsManager.primaryPurple.withValues(alpha: 0.28),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  static BoxDecoration continueReadingIcon() {
    return BoxDecoration(
      color: ColorsManager.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: ColorsManager.white.withValues(alpha: 0.24)),
    );
  }

  static ButtonStyle continueReadingButton() {
    return FilledButton.styleFrom(
      backgroundColor: ColorsManager.white,
      foregroundColor: ColorsManager.darkPurple,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
    );
  }

  static BoxDecoration entryCard() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(18.r),
      border: Border.all(
        color: ColorsManager.primaryGold.withValues(alpha: 0.45),
      ),
      boxShadow: [
        BoxShadow(
          color: ColorsManager.primaryGold.withValues(alpha: 0.12),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  static BoxDecoration entryCardIcon() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          ColorsManager.primaryGold,
          ColorsManager.primaryGold.withValues(alpha: 0.75),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(14.r),
    );
  }

  // ── index ──────────────────────────────────────────────────────────────

  static BoxDecoration tabSelector(QuranSurfaceColors colors) {
    return BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: colors.border),
    );
  }

  static BoxDecoration tabSelectorPill(QuranSurfaceColors colors) {
    return BoxDecoration(
      color: colors.accent,
      borderRadius: BorderRadius.circular(10.r),
    );
  }

  static BoxDecoration indexTile(
    QuranSurfaceColors colors, {
    required bool isCurrent,
  }) {
    return BoxDecoration(
      color: isCurrent ? colors.selection : colors.surface,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(
        color: isCurrent ? colors.accent.withValues(alpha: 0.5) : colors.border,
      ),
    );
  }

  static BoxDecoration numberBadge(QuranSurfaceColors colors) {
    return BoxDecoration(
      color: colors.accent.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: colors.accent.withValues(alpha: 0.55)),
    );
  }

  static InputDecoration filterField(QuranSurfaceColors colors, String hint) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14.r),
      borderSide: BorderSide(color: colors.border),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: colors.subtitle, fontSize: 13.sp),
      prefixIcon: Icon(Icons.search_rounded, color: colors.accent),
      filled: true,
      fillColor: colors.surface,
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: colors.accent, width: 1.4),
      ),
    );
  }

  // ── reader ─────────────────────────────────────────────────────────────

  static ShapeBorder readerBottomBarShape(MushafColors colors) {
    return Border(top: BorderSide(color: colors.gold.withValues(alpha: 0.5)));
  }

  static BoxDecoration pageChip(MushafColors colors) {
    return BoxDecoration(
      color: colors.banner,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: colors.gold.withValues(alpha: 0.7)),
    );
  }

  static BoxDecoration focusBar(MushafColors colors, Color ruleColor) {
    return BoxDecoration(
      color: colors.paper,
      borderRadius: BorderRadius.circular(22.r),
      border: Border.all(color: ruleColor.withValues(alpha: 0.55)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.14),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static ShapeBorder sheetShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    );
  }

  static BoxDecoration sheetHandle(QuranSurfaceColors colors) {
    return BoxDecoration(
      color: colors.border,
      borderRadius: BorderRadius.circular(4.r),
    );
  }

  /// The framed box a verse or a tapped word is shown in.
  static BoxDecoration quranTextBox(QuranSurfaceColors colors) {
    return BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: colors.mushaf.gold),
    );
  }

  static BoxDecoration evidenceBox(QuranSurfaceColors colors) {
    return BoxDecoration(
      color: colors.surface.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: colors.border),
    );
  }

  static BoxDecoration ruleSwatch(Color color) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(4.r),
    );
  }

  static BoxDecoration ruleChip(Color ruleColor) {
    return BoxDecoration(
      color: ruleColor.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: ruleColor.withValues(alpha: 0.45)),
    );
  }

  static BoxDecoration infoChip(QuranSurfaceColors colors) {
    return BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: colors.border),
    );
  }

  static BoxDecoration themeOption(
    MushafColors preview, {
    required bool selected,
    required Color selectedBorder,
  }) {
    return BoxDecoration(
      color: preview.paper,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(
        color: selected ? selectedBorder : preview.gold.withValues(alpha: 0.6),
        width: selected ? 2 : 1,
      ),
    );
  }

  static BoxDecoration actionButton(
    QuranSurfaceColors colors, {
    bool active = false,
  }) {
    return BoxDecoration(
      color: active ? colors.selection : colors.surface,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(
        color: active ? colors.accent.withValues(alpha: 0.6) : colors.border,
      ),
    );
  }

  // ── search ─────────────────────────────────────────────────────────────

  static BoxDecoration searchHitCard() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: ColorsManager.mediumGray),
    );
  }

  static Color get searchMatchHighlight =>
      ColorsManager.primaryGold.withValues(alpha: 0.32);

  static BoxDecoration searchField() {
    return BoxDecoration(
      color: ColorsManager.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: ColorsManager.white.withValues(alpha: 0.26)),
    );
  }

  // ── tajweed guide ──────────────────────────────────────────────────────

  static BoxDecoration guideIntroCard() {
    return BoxDecoration(
      color: ColorsManager.primaryPurple.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(
        color: ColorsManager.primaryPurple.withValues(alpha: 0.18),
      ),
    );
  }

  /// Rounded corners need a uniform border, so the rule's colour is drawn as
  /// a separate stripe inside the card rather than as one side of it.
  static BoxDecoration guideRuleCard() {
    return BoxDecoration(
      color: ColorsManager.cardBackground,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: ColorsManager.mediumGray),
    );
  }

  static BoxDecoration guideNoteCard() {
    return BoxDecoration(
      color: ColorsManager.warning.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: ColorsManager.warning.withValues(alpha: 0.3)),
    );
  }
}
