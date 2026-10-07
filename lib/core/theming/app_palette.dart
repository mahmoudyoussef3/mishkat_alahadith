import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_grade.dart';

@immutable
class AppPalette {
  final Brightness brightness;

  final Color primaryPurple;
  final Color darkPurpleText;
  final Color purpleText;
  final Color hadithGood;

  final Color primaryGold;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  final Color primaryBackground;
  final Color secondaryBackground;
  final Color offWhite;
  final Color cardBackground;
  final Color elevatedSurface;

  final Color lightGray;
  final Color mediumGray;
  final Color gray;
  final Color darkGray;

  final Color primaryText;
  final Color secondaryText;
  final Color disabledText;

  final Color shimmerBase;
  final Color shimmerHighlight;

  /// Brand-tinted fill for chips, selected states and icon wells.
  final Color primarySoft;

  /// Gold-tinted fill for highlights such as "today" or featured items.
  final Color goldSoft;

  /// Gradient for the large page headers.
  final Color headerStart;
  final Color headerEnd;

  /// Shadow tint; near-invisible in dark mode, where borders carry elevation.
  final Color shadow;

  /// Hairline around cards, fields and outlined buttons. Borders carry
  /// elevation instead of heavy shadows.
  final Color border;

  /// Deep "night" surface behind featured content such as the hadith of the
  /// day; always paired with light text.
  final Color heroBackground;

  /// Bright gold for small badges drawn on [heroBackground].
  final Color goldBright;

  /// Text on [goldBright]; dark in both themes.
  final Color onGoldBright;

  /// Text and icons drawn on [goldSoft].
  final Color goldInk;

  /// Fill behind the authentic ("sahih") grade and other success states.
  final Color successSoft;

  /// Fill behind the weak ("daif") grade and other error states.
  final Color errorSoft;

  /// Drop shadow under book covers, the only shadowed element in the UI.
  final Color coverShadow;

  /// Warm "manuscript" frame around the hadith of the day.
  final Color featuredBorder;

  /// Inner rule of the hadith of the day's double frame.
  final Color featuredInnerBorder;

  /// Parchment wash at the top of the hadith of the day, fading into
  /// [cardBackground].
  final Color featuredWash;

  /// Soft gold glow under the hadith of the day; clear in dark mode, where
  /// the frame carries the elevation.
  final Color featuredGlow;

  /// Gold hairlines beside the ornament on the hadith of the day.
  final Color ornament;

  /// The ornament glyph ("۞") itself.
  final Color ornamentInk;

  /// Authentic ("sahih") grade as text or a thin accent; brighter than
  /// [success] in dark mode so a 4px bar still reads.
  final Color gradeSahih;

  /// Fill behind [gradeSahih] text.
  final Color gradeSahihSoft;

  /// Good ("hasan") grade as text or a thin accent.
  final Color gradeHasan;

  const AppPalette._({
    required this.brightness,
    required this.primaryPurple,
    required this.darkPurpleText,
    required this.purpleText,
    required this.hadithGood,
    required this.primaryGold,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.primaryBackground,
    required this.secondaryBackground,
    required this.offWhite,
    required this.cardBackground,
    required this.elevatedSurface,
    required this.lightGray,
    required this.mediumGray,
    required this.gray,
    required this.darkGray,
    required this.primaryText,
    required this.secondaryText,
    required this.disabledText,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.primarySoft,
    required this.goldSoft,
    required this.headerStart,
    required this.headerEnd,
    required this.shadow,
    required this.border,
    required this.heroBackground,
    required this.goldBright,
    required this.onGoldBright,
    required this.goldInk,
    required this.successSoft,
    required this.errorSoft,
    required this.coverShadow,
    required this.featuredBorder,
    required this.featuredInnerBorder,
    required this.featuredWash,
    required this.featuredGlow,
    required this.ornament,
    required this.ornamentInk,
    required this.gradeSahih,
    required this.gradeSahihSoft,
    required this.gradeHasan,
  });

  bool get isDark => brightness == Brightness.dark;

  /// Accent for [grade] in hadith lists: the bar beside a hadith and its
  /// grade label.
  Color gradeAccent(HadithGrade grade) => switch (grade) {
    HadithGrade.sahih => gradeSahih,
    HadithGrade.hasan => gradeHasan,
    HadithGrade.daif => error,
  };

  /// Fill behind a [grade] badge, paired with [gradeAccent] text.
  Color gradeSoft(HadithGrade grade) => switch (grade) {
    HadithGrade.sahih => gradeSahihSoft,
    HadithGrade.hasan => goldSoft,
    HadithGrade.daif => errorSoft,
  };

  /// Warm "paper and ink" palette for long reading sessions: no pure white
  /// surfaces and no pure black text, keeping body text around 13:1 contrast.
  static const AppPalette light = AppPalette._(
    brightness: Brightness.light,
    primaryPurple: Color(0xFF4E3BA8),
    darkPurpleText: Color(0xFF2E2366),
    purpleText: Color(0xFF4E3BA8),
    hadithGood: Color(0xFF8A6418),
    primaryGold: Color(0xFFA2741C),
    success: Color(0xFF2A7350),
    warning: Color(0xFFB26A12),
    error: Color(0xFFA63A33),
    info: Color(0xFF2D6AA6),
    primaryBackground: Color(0xFFF1EDE5),
    secondaryBackground: Color(0xFFF7F4EE),
    offWhite: Color(0xFFF3EFE8),
    cardBackground: Color(0xFFFFFDF9),
    elevatedSurface: Color(0xFFFFFEFB),
    lightGray: Color(0xFFEFEBE3),
    mediumGray: Color(0xFFE2DBCD),
    gray: Color(0xFF9A94A2),
    darkGray: Color(0xFF575160),
    primaryText: Color(0xFF24202C),
    secondaryText: Color(0xFF6A6373),
    disabledText: Color(0xFFB3AEB8),
    shimmerBase: Color(0xFFECE8E0),
    shimmerHighlight: Color(0xFFF8F6F1),
    primarySoft: Color(0xFFEEEAF7),
    goldSoft: Color(0xFFF5ECD8),
    headerStart: Color(0xFF4E3BA8),
    headerEnd: Color(0xFF3A2B86),
    shadow: Color(0x1424202C),
    border: Color(0xFFE9E3D7),
    heroBackground: Color(0xFF1D1638),
    goldBright: Color(0xFFE8C77E),
    onGoldBright: Color(0xFF2B1F05),
    goldInk: Color(0xFF5C4210),
    successSoft: Color(0xFFE3EFE7),
    errorSoft: Color(0xFFF7E4E2),
    coverShadow: Color(0x8C24202C),
    featuredBorder: Color(0xFFE5D9BF),
    featuredInnerBorder: Color(0xFFEADFC6),
    featuredWash: Color(0xFFFBF6EA),
    featuredGlow: Color(0x99A2741C),
    ornament: Color(0xFFD9C08A),
    ornamentInk: Color(0xFFA2741C),
    // The design's #2E7D55 and #A2741C, darkened just enough to meet
    // WCAG AA as small text.
    gradeSahih: Color(0xFF2A7350),
    gradeSahihSoft: Color(0xFFE3EFE7),
    gradeHasan: Color(0xFF8A6418),
  );

  /// Soft night palette: deep charcoal instead of pure black (avoids halation
  /// on OLED), off-white text, and desaturated accents that do not glow.
  static const AppPalette dark = AppPalette._(
    brightness: Brightness.dark,
    primaryPurple: Color(0xFF7D69CF),
    darkPurpleText: Color(0xFFC7BCF3),
    purpleText: Color(0xFFAFA0EC),
    hadithGood: Color(0xFFC9A55A),
    primaryGold: Color(0xFFC9A55A),
    success: Color(0xFF4E9E77),
    warning: Color(0xFFC98B42),
    error: Color(0xFFDB6B64),
    info: Color(0xFF5C93CB),
    primaryBackground: Color(0xFF121116),
    secondaryBackground: Color(0xFF16151B),
    offWhite: Color(0xFF1A1920),
    cardBackground: Color(0xFF1E1C24),
    elevatedSurface: Color(0xFF25232C),
    lightGray: Color(0xFF29272F),
    mediumGray: Color(0xFF34313D),
    gray: Color(0xFF8A8594),
    darkGray: Color(0xFFB8B3C0),
    primaryText: Color(0xFFE4E0E8),
    secondaryText: Color(0xFFA8A3B0),
    disabledText: Color(0xFF5D5966),
    shimmerBase: Color(0xFF201E26),
    shimmerHighlight: Color(0xFF2C2A33),
    primarySoft: Color(0xFF2C2840),
    goldSoft: Color(0xFF2D2819),
    headerStart: Color(0xFF342B57),
    headerEnd: Color(0xFF231F38),
    shadow: Color(0x33000000),
    border: Color(0xFF2E2B36),
    heroBackground: Color(0xFF1A1530),
    goldBright: Color(0xFFE8C77E),
    onGoldBright: Color(0xFF2B1F05),
    goldInk: Color(0xFFE3C987),
    successSoft: Color(0xFF1A2620),
    errorSoft: Color(0xFF2B1A19),
    coverShadow: Color(0x99000000),
    featuredBorder: Color(0xFF3A3123),
    featuredInnerBorder: Color(0xFF332C20),
    featuredWash: Color(0xFF241F18),
    featuredGlow: Color(0x00000000),
    ornament: Color(0xFF8C6F3A),
    ornamentInk: Color(0xFFE8C77E),
    gradeSahih: Color(0xFF7FD3A2),
    gradeSahihSoft: Color(0xFF17301F),
    gradeHasan: Color(0xFFE8C77E),
  );
}
