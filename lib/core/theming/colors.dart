import 'package:flutter/material.dart';

import 'app_palette.dart';

class ColorsManager {
  static AppPalette _palette = AppPalette.light;

  static AppPalette get palette => _palette;

  static bool get isDark => _palette.isDark;

  static void usePalette(AppPalette palette) => _palette = palette;

  static Color get primaryPurple => _palette.primaryPurple;


  static const Color secondaryPurple = Color(0xFF8E7AD6);


  static Color get primaryGold => _palette.primaryGold;

  static const Color lightPurple = Color(0xFFB7ABE0);

  static const Color darkPurple = Color(0xFF4A3A94);

  static const Color accentPurple = Color(0xFF7259D6);

  static Color get primaryBackground => _palette.primaryBackground;

  static Color get secondaryBackground => _palette.secondaryBackground;

  static Color get cardBackground => _palette.cardBackground;

  static const Color overlayBackground = Color(0x80000000);

  static const Color white = Color(0xFFFFFFFF);

  static Color get offWhite => _palette.offWhite;

  static Color get lightGray => _palette.lightGray;

  static Color get mediumGray => _palette.mediumGray;

  static Color get gray => _palette.gray;

  static Color get darkGray => _palette.darkGray;

  static const Color black = Color(0xFF212121);

  static Color get primaryText => _palette.primaryText;

  static Color get secondaryText => _palette.secondaryText;

  static Color get disabledText => _palette.disabledText;

  static const Color inverseText = Color(0xFFFFFFFF);

  static Color get purpleText => _palette.purpleText;

  static Color get darkPurpleText => _palette.darkPurpleText;

  static Color get elevatedSurface => _palette.elevatedSurface;

  static Color get shimmerBase => _palette.shimmerBase;
  static Color get shimmerHighlight => _palette.shimmerHighlight;

  static Color get success => _palette.success;

  static Color get warning => _palette.warning;

  static Color get error => _palette.error;

  static Color get info => _palette.info;

  static Color get hadithAuthentic => _palette.success;

  static Color get hadithGood => _palette.hadithGood;

  static Color get hadithWeak => _palette.warning;

  static Color get primaryGreen => primaryPurple;

  static const Color secondaryGreen = secondaryPurple;

  static const Color primaryNavy = darkPurple;

  static Color get accentOrange => primaryGold;

  static Color get mainBlue => primaryPurple;

  static const Color lightBlue = lightPurple;

  static const Color darkBlue = darkPurple;

  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  static List<Color> get primaryColors => [
    primaryPurple,
    secondaryPurple,
    accentPurple,
  ];

  static List<Color> get accentColors => [
    primaryGold,
    hadithAuthentic,
    hadithGood,
  ];
}
