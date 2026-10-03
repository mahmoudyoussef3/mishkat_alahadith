import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/theming/app_palette.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  for (final palette in [AppPalette.light, AppPalette.dark]) {
    final name = palette.isDark ? 'dark' : 'light';

    group('$name palette', () {
      test('primary text meets WCAG AAA on every reading surface', () {
        for (final surface in [
          palette.secondaryBackground,
          palette.cardBackground,
          palette.elevatedSurface,
        ]) {
          expect(_contrast(palette.primaryText, surface), greaterThan(7));
        }
      });

      test('primary text avoids glare from maximum contrast', () {
        expect(
          _contrast(palette.primaryText, palette.secondaryBackground),
          lessThan(16),
        );
      });

      test('secondary text meets WCAG AA on cards', () {
        expect(
          _contrast(palette.secondaryText, palette.cardBackground),
          greaterThan(4.5),
        );
      });

      test('accent and status colors stay visible on cards', () {
        for (final accent in [
          palette.primaryPurple,
          palette.purpleText,
          palette.primaryGold,
          palette.success,
          palette.warning,
          palette.error,
          palette.info,
          palette.hadithGood,
        ]) {
          expect(_contrast(accent, palette.cardBackground), greaterThan(3));
        }
      });

      test('brand text stays readable on brand-tinted fills', () {
        expect(
          _contrast(palette.purpleText, palette.primarySoft),
          greaterThan(4.5),
        );
      });

      test('white header text meets WCAG AA across the header gradient', () {
        for (final stop in [palette.headerStart, palette.headerEnd]) {
          expect(_contrast(Colors.white, stop), greaterThan(4.5));
        }
      });
    });
  }
}
