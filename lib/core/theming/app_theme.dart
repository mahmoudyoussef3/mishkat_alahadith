import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_palette.dart';

class AppTheme {
  AppTheme._();

  static const String _fontFamily = 'Cairo';

  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 24;

  static ThemeData get lightTheme => _build(AppPalette.light);

  static ThemeData get darkTheme => _build(AppPalette.dark);

  /// Transparent system bars whose icons contrast with the page background.
  static SystemUiOverlayStyle systemBarsStyle(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final iconBrightness = isDark ? Brightness.light : Brightness.dark;
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: iconBrightness,
      statusBarBrightness: brightness,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: iconBrightness,
      systemNavigationBarContrastEnforced: false,
    );
  }

  static ThemeData _build(AppPalette palette) {
    final isDark = palette.isDark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: palette.primaryPurple,
      brightness: palette.brightness,
    ).copyWith(
      primary: palette.primaryPurple,
      onPrimary: Colors.white,
      primaryContainer: palette.primarySoft,
      onPrimaryContainer: palette.darkPurpleText,
      secondary: palette.primaryGold,
      onSecondary: isDark ? const Color(0xFF261A00) : Colors.white,
      secondaryContainer: palette.goldSoft,
      onSecondaryContainer:
          isDark ? palette.primaryGold : const Color(0xFF5C4210),
      surface: palette.cardBackground,
      onSurface: palette.primaryText,
      onSurfaceVariant: palette.secondaryText,
      // Ordered lightest → darkest in light mode and darkest → lightest in
      // dark mode, as Material 3 expects.
      surfaceContainerLowest:
          isDark ? palette.primaryBackground : palette.elevatedSurface,
      surfaceContainerLow:
          isDark ? palette.secondaryBackground : palette.cardBackground,
      surfaceContainer: isDark ? palette.cardBackground : palette.offWhite,
      surfaceContainerHigh:
          isDark ? palette.elevatedSurface : palette.lightGray,
      surfaceContainerHighest: isDark ? palette.lightGray : palette.mediumGray,
      surfaceTint: Colors.transparent,
      outline: palette.gray,
      outlineVariant: palette.mediumGray,
      error: palette.error,
      onError: Colors.white,
      inverseSurface: isDark ? palette.darkGray : palette.primaryText,
      onInverseSurface:
          isDark ? palette.secondaryBackground : palette.cardBackground,
      inversePrimary: isDark ? palette.headerEnd : palette.darkPurpleText,
    );

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    );
    const buttonText = TextStyle(
      fontFamily: _fontFamily,
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );

    return ThemeData(
      fontFamily: _fontFamily,
      useMaterial3: true,
      brightness: palette.brightness,
      colorScheme: colorScheme,
      textTheme: _textTheme(palette),
      scaffoldBackgroundColor: palette.secondaryBackground,
      canvasColor: palette.secondaryBackground,
      cardColor: palette.cardBackground,
      dividerColor: palette.mediumGray,
      hintColor: palette.gray,
      disabledColor: palette.disabledText,
      iconTheme: IconThemeData(color: palette.darkGray),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.secondaryBackground,
        foregroundColor: palette.primaryText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        // No titleTextStyle here: AppBar then styles its title with
        // textTheme.titleLarge in its own foregroundColor.
      ),
      cardTheme: CardThemeData(
        color: palette.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: palette.mediumGray),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primaryPurple,
          foregroundColor: Colors.white,
          disabledBackgroundColor: palette.lightGray,
          disabledForegroundColor: palette.disabledText,
          elevation: 0,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.primaryPurple,
          foregroundColor: Colors.white,
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.purpleText,
          side: BorderSide(color: palette.primaryPurple.withValues(alpha: 0.4)),
          minimumSize: const Size(64, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          shape: buttonShape,
          textStyle: buttonText,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.purpleText,
          shape: buttonShape,
          textStyle: buttonText.copyWith(fontSize: 14),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: palette.darkGray),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
        ),
        extendedTextStyle: buttonText,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          fontFamily: _fontFamily,
          color: palette.secondaryText,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          color: palette.secondaryText,
        ),
        floatingLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          color: palette.purpleText,
        ),
        prefixIconColor: palette.gray,
        suffixIconColor: palette.gray,
        fillColor: palette.lightGray,
        errorStyle: TextStyle(fontFamily: _fontFamily, color: palette.error),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: palette.primaryPurple,
        selectionColor: palette.primaryPurple.withValues(alpha: 0.28),
        selectionHandleColor: palette.primaryPurple,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.lightGray,
        selectedColor: palette.primarySoft,
        disabledColor: palette.lightGray,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: palette.primaryText,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: palette.purpleText,
        ),
        checkmarkColor: palette.purpleText,
        iconTheme: IconThemeData(color: palette.purpleText, size: 18),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.elevatedSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: palette.primaryText,
        ),
        contentTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 15,
          height: 1.6,
          color: palette.secondaryText,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.elevatedSurface,
        modalBackgroundColor: palette.elevatedSurface,
        surfaceTintColor: Colors.transparent,
        dragHandleColor: palette.mediumGray,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXl)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF34313D) : palette.primaryText,
        contentTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? palette.primaryText : palette.cardBackground,
        ),
        actionTextColor: isDark ? palette.purpleText : palette.primarySoft,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: palette.elevatedSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shadowColor: palette.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: palette.mediumGray),
        ),
        textStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          color: palette.primaryText,
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? palette.elevatedSurface : palette.primaryText,
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        textStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 12,
          color: isDark ? palette.primaryText : palette.cardBackground,
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: palette.primaryBackground,
        surfaceTintColor: Colors.transparent,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: palette.darkGray,
        textColor: palette.primaryText,
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: palette.primaryText,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          fontSize: 13,
          color: palette.secondaryText,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.mediumGray,
        thickness: 1,
        space: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.primaryPurple,
        linearTrackColor: palette.primarySoft,
        circularTrackColor: Colors.transparent,
        refreshBackgroundColor: palette.elevatedSurface,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected)
                  ? Colors.white
                  : palette.gray,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected)
                  ? palette.primaryPurple
                  : palette.lightGray,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected)
                  ? Colors.transparent
                  : palette.mediumGray,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected)
                  ? palette.primaryPurple
                  : Colors.transparent,
        ),
        checkColor: const WidgetStatePropertyAll(Colors.white),
        side: BorderSide(color: palette.gray, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected)
                  ? palette.primaryPurple
                  : palette.gray,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: palette.purpleText,
        unselectedLabelColor: palette.secondaryText,
        indicatorColor: palette.primaryPurple,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: _fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: palette.error,
        textColor: Colors.white,
      ),
    );
  }

  /// Cairo for interface text. Line heights come from Material's type scale;
  /// letter spacing is zeroed because any spacing pulls apart joined Arabic
  /// letters.
  static TextTheme _textTheme(AppPalette palette) {
    TextStyle style(double size, FontWeight weight, [Color? color]) =>
        TextStyle(
          fontFamily: _fontFamily,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: 0,
          color: color ?? palette.primaryText,
        );

    return TextTheme(
      displayLarge: style(32, FontWeight.w700),
      displayMedium: style(28, FontWeight.w700),
      displaySmall: style(24, FontWeight.w700),
      headlineLarge: style(22, FontWeight.w700),
      headlineMedium: style(20, FontWeight.w700),
      headlineSmall: style(18, FontWeight.w700),
      titleLarge: style(17, FontWeight.w700),
      titleMedium: style(15, FontWeight.w600),
      titleSmall: style(14, FontWeight.w600),
      bodyLarge: style(16, FontWeight.w400),
      bodyMedium: style(14, FontWeight.w400),
      bodySmall: style(12, FontWeight.w400, palette.secondaryText),
      labelLarge: style(14, FontWeight.w600),
      labelMedium: style(12, FontWeight.w600),
      labelSmall: style(11, FontWeight.w500, palette.secondaryText),
    );
  }
}
