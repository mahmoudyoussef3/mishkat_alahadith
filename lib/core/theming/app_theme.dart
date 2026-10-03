import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'colors.dart';

class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Cairo';

  static ThemeData get lightTheme =>
      ThemeData(fontFamily: _fontFamily, useMaterial3: true);

  static ThemeData get darkTheme {
    const palette = AppPalette.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: palette.primaryPurple,
      brightness: Brightness.dark,
    ).copyWith(
      secondary: ColorsManager.primaryGold,
      onSecondary: const Color(0xFF261A00),
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
      error: ColorsManager.error,
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
