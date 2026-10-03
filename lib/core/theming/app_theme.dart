import 'package:flutter/material.dart';

import 'app_palette.dart';

class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Cairo';

  static ThemeData get lightTheme => _build(AppPalette.light);

  static ThemeData get darkTheme => _build(AppPalette.dark);

  static ThemeData _build(AppPalette palette) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: palette.primaryPurple,
      brightness: palette.brightness,
    ).copyWith(
      secondary: palette.primaryGold,
      onSecondary: palette.isDark ? const Color(0xFF261A00) : Colors.white,
      surface: palette.cardBackground,
      onSurface: palette.primaryText,
      onSurfaceVariant: palette.secondaryText,
      surfaceContainerLowest: palette.primaryBackground,
      surfaceContainerLow: palette.secondaryBackground,
      surfaceContainer: palette.cardBackground,
      surfaceContainerHigh: palette.elevatedSurface,
      surfaceContainerHighest: palette.lightGray,
      outline: palette.mediumGray,
      outlineVariant: palette.lightGray,
      error: palette.error,
    );

    return ThemeData(
      fontFamily: _fontFamily,
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.secondaryBackground,
      canvasColor: palette.secondaryBackground,
      cardColor: palette.cardBackground,
      dividerColor: palette.mediumGray,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.secondaryBackground,
        foregroundColor: palette.primaryText,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: palette.cardBackground,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.elevatedSurface,
        surfaceTintColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.elevatedSurface,
        modalBackgroundColor: palette.elevatedSurface,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.elevatedSurface,
        surfaceTintColor: Colors.transparent,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: palette.primaryBackground,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(color: palette.mediumGray),
    );
  }
}
