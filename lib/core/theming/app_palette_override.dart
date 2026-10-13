import 'package:flutter/material.dart';

import 'app_palette.dart';
import 'app_theme.dart';
import 'colors.dart';

/// Draws a subtree in a palette other than the app's, such as the dark
/// palette around a mushaf page set to night while the app itself is light.
///
/// Sets both the [Theme] (for Material widgets) and the palette that
/// [AppPaletteOverride.of] returns (for widgets drawn from palette tokens).
/// Both are inherited themes, so sheets and dialogs opened from inside the
/// subtree are drawn in the same palette.
class AppPaletteOverride extends StatelessWidget {
  const AppPaletteOverride({
    super.key,
    required this.palette,
    required this.child,
  });

  final AppPalette palette;
  final Widget child;

  // Built once: a theme is costly to build and this rebuilds with its
  // parent.
  static final ThemeData _lightTheme = AppTheme.lightTheme;
  static final ThemeData _darkTheme = AppTheme.darkTheme;

  /// The palette to draw in at [context]: the nearest override's, otherwise
  /// the app's own.
  static AppPalette of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PaletteScope>()?.palette ??
      ColorsManager.palette;

  @override
  Widget build(BuildContext context) {
    return _PaletteScope(
      palette: palette,
      child: Theme(
        data: palette.isDark ? _darkTheme : _lightTheme,
        child: child,
      ),
    );
  }
}

class _PaletteScope extends InheritedTheme {
  const _PaletteScope({required this.palette, required super.child});

  final AppPalette palette;

  @override
  Widget wrap(BuildContext context, Widget child) =>
      _PaletteScope(palette: palette, child: child);

  @override
  bool updateShouldNotify(_PaletteScope oldWidget) =>
      palette != oldWidget.palette;
}
