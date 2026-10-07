import 'package:flutter/painting.dart';
import 'package:mushaf_text/mushaf_text.dart';

import 'app_palette.dart';

/// The mushaf page in the app's colours: the reading surface as paper, the
/// app's ink for the text, its gold family for surah banners and ayah
/// rosettes, and a brand wash behind a selected ayah.
abstract final class MushafPalette {
  static final MushafColors light = _from(AppPalette.light);

  /// Keeps the package's night tajweed colours, which are lifted towards
  /// white so the rules stay legible on dark paper.
  static final MushafColors dark = _from(
    AppPalette.dark,
    tajweed: MushafColors.dark.tajweedOverrides,
  );

  /// The page drawn in [palette]'s brightness.
  static MushafColors of(AppPalette palette) => palette.isDark ? dark : light;

  static MushafColors _from(
    AppPalette palette, {
    Map<TajweedRule, Color> tajweed = const {},
  }) {
    final paper = palette.secondaryBackground;
    // Opaque blends: the page paints these over its own paper, and a frame
    // in full-strength gold would outweigh the text it surrounds.
    Color over(Color color, double alpha) =>
        Color.alphaBlend(color.withValues(alpha: alpha), paper);

    return MushafColors(
      paper: paper,
      ink: palette.primaryText,
      accent: palette.goldInk,
      banner: palette.goldSoft,
      gold: over(palette.primaryGold, 0.6),
      highlight: over(palette.primaryPurple, 0.16),
      tajweedOverrides: tajweed,
    );
  }
}
