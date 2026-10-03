import 'package:flutter/material.dart';

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
  });

  bool get isDark => brightness == Brightness.dark;

  /// Warm "paper and ink" palette for long reading sessions: no pure white
  /// surfaces and no pure black text, keeping body text around 13:1 contrast.
  static const AppPalette light = AppPalette._(
    brightness: Brightness.light,
    primaryPurple: Color(0xFF5F48B8),
    darkPurpleText: Color(0xFF46358F),
    purpleText: Color(0xFF5F48B8),
    hadithGood: Color(0xFF86489E),
    primaryGold: Color(0xFFA87A22),
    success: Color(0xFF2E7D55),
    warning: Color(0xFFB26A12),
    error: Color(0xFFB9403A),
    info: Color(0xFF2D6AA6),
    primaryBackground: Color(0xFFF3F1EC),
    secondaryBackground: Color(0xFFF8F6F1),
    offWhite: Color(0xFFF5F3EE),
    cardBackground: Color(0xFFFFFDF8),
    elevatedSurface: Color(0xFFFFFEFB),
    lightGray: Color(0xFFEEEBE5),
    mediumGray: Color(0xFFE4DFD6),
    gray: Color(0xFF8E8996),
    darkGray: Color(0xFF575160),
    primaryText: Color(0xFF2B2733),
    secondaryText: Color(0xFF605A69),
    disabledText: Color(0xFFB3AEB8),
    shimmerBase: Color(0xFFECE9E3),
    shimmerHighlight: Color(0xFFF7F5F1),
  );

  /// Soft night palette: deep charcoal instead of pure black (avoids halation
  /// on OLED), off-white text, and desaturated accents that do not glow.
  static const AppPalette dark = AppPalette._(
    brightness: Brightness.dark,
    primaryPurple: Color(0xFF7D69CF),
    darkPurpleText: Color(0xFFC7BCF3),
    purpleText: Color(0xFFAFA0EC),
    hadithGood: Color(0xFFA97CC2),
    primaryGold: Color(0xFFC9A55A),
    success: Color(0xFF4E9E77),
    warning: Color(0xFFC98B42),
    error: Color(0xFFD2605A),
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
  );
}
