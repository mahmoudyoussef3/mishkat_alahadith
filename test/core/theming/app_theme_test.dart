import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/theming/app_palette.dart';
import 'package:mishkat_almasabih/core/theming/app_theme.dart';

void main() {
  final themes = {
    AppPalette.light: AppTheme.lightTheme,
    AppPalette.dark: AppTheme.darkTheme,
  };

  themes.forEach((palette, theme) {
    final name = palette.isDark ? 'dark' : 'light';

    group('$name theme', () {
      test('uses the palette brightness', () {
        expect(theme.brightness, palette.brightness);
        expect(theme.colorScheme.brightness, palette.brightness);
      });

      test('paints pages with the palette background', () {
        expect(theme.scaffoldBackgroundColor, palette.secondaryBackground);
      });

      test('pins the Material primary to the brand colour', () {
        expect(theme.colorScheme.primary, palette.primaryPurple);
      });

      test('orders surface containers from the page outward', () {
        final scheme = theme.colorScheme;
        final luminances =
            [
              scheme.surfaceContainerLowest,
              scheme.surfaceContainerLow,
              scheme.surfaceContainer,
              scheme.surfaceContainerHigh,
              scheme.surfaceContainerHighest,
            ].map((c) => c.computeLuminance()).toList();
        final sorted = [...luminances]..sort();
        expect(luminances, palette.isDark ? sorted : sorted.reversed.toList());
      });
    });
  });

  test('system bar icons contrast with the page in each theme', () {
    expect(
      AppTheme.systemBarsStyle(Brightness.light).statusBarIconBrightness,
      Brightness.dark,
    );
    expect(
      AppTheme.systemBarsStyle(Brightness.dark).statusBarIconBrightness,
      Brightness.light,
    );
  });
}
