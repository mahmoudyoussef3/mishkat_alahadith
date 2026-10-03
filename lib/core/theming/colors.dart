import 'package:flutter/material.dart';

import 'app_palette.dart';

class ColorsManager {
  static AppPalette _palette = AppPalette.light;

  static AppPalette get palette => _palette;

  static bool get isDark => _palette.isDark;

  static void usePalette(AppPalette palette) => _palette = palette;

  static Color get primaryPurple => _palette.primaryPurple;


  static const Color secondaryPurple = Color(0xFF9D7BF0);


  static const Color primaryGold = Color(0xFFFFB300);

  static const Color lightPurple = Color(0xFFB39DDB);

  static const Color darkPurple = Color(0xFF5E35B1);

  static const Color accentPurple = Color(0xFF7C4DFF);

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

  static const Color success = Color(0xFF4CAF50);

  static const Color warning = Color(0xFFFF9800);

  static const Color error = Color(0xFFE53935);

  static const Color info = Color(0xFF2196F3);

  static const Color hadithAuthentic = Color(0xFF4CAF50);

  static Color get hadithGood => _palette.hadithGood;

  static const Color hadithWeak = Color(0xFFFF9800);

  static Color get primaryGreen => primaryPurple;

  static const Color secondaryGreen = secondaryPurple;

  static const Color primaryNavy = darkPurple;

  static const Color accentOrange = primaryGold;

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
