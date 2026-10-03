import 'package:flutter/material.dart';

@immutable
class AppPalette {
  final Brightness brightness;

  final Color primaryPurple;
  final Color darkPurpleText;
  final Color purpleText;
  final Color hadithGood;

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

  static const AppPalette light = AppPalette._(
    brightness: Brightness.light,
    primaryPurple: Color(0xFF7440E9),
    darkPurpleText: Color(0xFF5E35B1),
    purpleText: Color(0xFF7440E9),
    hadithGood: Color(0xFF9C27B0),
    primaryBackground: Color(0xFFFAFAFA),
    secondaryBackground: Color(0xFFFFFFFF),
    offWhite: Color(0xFFFAFAFA),
    cardBackground: Color(0xFFFFFFFF),
    elevatedSurface: Color(0xFFFFFFFF),
    lightGray: Color(0xFFF5F5F5),
    mediumGray: Color(0xFFE0E0E0),
    gray: Color(0xFF9E9E9E),
    darkGray: Color(0xFF616161),
    primaryText: Color(0xFF212121),
    secondaryText: Color(0xFF757575),
    disabledText: Color(0xFFBDBDBD),
    shimmerBase: Color(0xFFE0E0E0),
    shimmerHighlight: Color(0xFFF5F5F5),
  );

  static const AppPalette dark = AppPalette._(
    brightness: Brightness.dark,
    primaryPurple: Color(0xFF8256F0),
    darkPurpleText: Color(0xFFC4B0FF),
    purpleText: Color(0xFFB49BFF),
    hadithGood: Color(0xFFBA68C8),
    primaryBackground: Color(0xFF0F0D15),
    secondaryBackground: Color(0xFF16131F),
    offWhite: Color(0xFF191623),
    cardBackground: Color(0xFF1D1A28),
    elevatedSurface: Color(0xFF242031),
    lightGray: Color(0xFF262233),
    mediumGray: Color(0xFF342F43),
    gray: Color(0xFF8F8A9E),
    darkGray: Color(0xFFB9B4C7),
    primaryText: Color(0xFFEDEAF4),
    secondaryText: Color(0xFFA9A4B9),
    disabledText: Color(0xFF5F5A6E),
    shimmerBase: Color(0xFF221E2E),
    shimmerHighlight: Color(0xFF302B3E),
  );
}
