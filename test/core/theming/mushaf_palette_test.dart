import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/theming/app_palette.dart';
import 'package:mishkat_almasabih/core/theming/mushaf_palette.dart';
import 'package:mushaf_text/mushaf_text.dart';

void main() {
  test('the light page is drawn on the app reading surface in its ink', () {
    expect(MushafPalette.light.paper, AppPalette.light.secondaryBackground);
    expect(MushafPalette.light.ink, AppPalette.light.primaryText);
    expect(MushafPalette.light.banner, AppPalette.light.goldSoft);
  });

  test('the dark page is drawn on the dark reading surface in its ink', () {
    expect(MushafPalette.dark.paper, AppPalette.dark.secondaryBackground);
    expect(MushafPalette.dark.ink, AppPalette.dark.primaryText);
    expect(MushafPalette.dark.banner, AppPalette.dark.goldSoft);
  });

  test('frames and the selection wash are opaque, so they paint cleanly', () {
    for (final colors in [MushafPalette.light, MushafPalette.dark]) {
      expect(colors.gold.a, 1.0);
      expect(colors.highlight.a, 1.0);
    }
  });

  test('a selected ayah stands out from the paper', () {
    for (final colors in [MushafPalette.light, MushafPalette.dark]) {
      expect(colors.highlight, isNot(colors.paper));
    }
  });

  test('keeps the lifted night tajweed colours on dark paper', () {
    const rule = TajweedRule.idghamGhunna;

    expect(
      MushafPalette.dark.tajweedColor(rule),
      MushafColors.dark.tajweedColor(rule),
    );
    expect(MushafPalette.light.tajweedColor(rule), rule.color);
  });

  test('picks the page for the palette brightness', () {
    expect(MushafPalette.of(AppPalette.light), same(MushafPalette.light));
    expect(MushafPalette.of(AppPalette.dark), same(MushafPalette.dark));
  });
}
