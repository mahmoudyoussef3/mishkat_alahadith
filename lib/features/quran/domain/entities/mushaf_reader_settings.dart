enum MushafThemeMode {
  /// Follows the app's light/dark theme.
  system,

  /// Cream paper and dark ink, as printed.
  day,

  /// Dark paper for reading at night.
  night,
}

/// How the reader lays the verses out.
enum MushafLayoutMode {
  /// The printed page, line for line. Its lines fill the screen's width, so
  /// its size follows the screen rather than [QuranFontScale].
  page,

  /// The page's verses as running text that wraps at any size, so it can be
  /// drawn at the reader's [QuranFontScale].
  flowing,
}

/// How large Quran text that wraps freely is drawn — the flowing layout and
/// the ayah sheet — as a multiple of its designed size.
enum QuranFontScale {
  small(0.85),
  medium(1.0),
  large(1.2),
  extraLarge(1.45),
  huge(1.75);

  const QuranFontScale(this.factor);

  final double factor;

  bool get isSmallest => this == values.first;

  bool get isLargest => this == values.last;

  /// The next size up, or this one when already the largest.
  QuranFontScale get larger => isLargest ? this : values[index + 1];

  /// The next size down, or this one when already the smallest.
  QuranFontScale get smaller => isSmallest ? this : values[index - 1];
}

class MushafReaderSettings {
  /// On by default; the reading settings can still switch it off.
  final bool tajweedEnabled;

  /// The natural madd is by far the most frequent rule, so colouring it tints
  /// most of the page — it gets its own switch, off by default.
  final bool naturalMaddEnabled;
  final MushafThemeMode themeMode;
  final MushafLayoutMode layoutMode;
  final QuranFontScale fontScale;

  const MushafReaderSettings({
    this.tajweedEnabled = true,
    this.naturalMaddEnabled = false,
    this.themeMode = MushafThemeMode.system,
    this.layoutMode = MushafLayoutMode.page,
    this.fontScale = QuranFontScale.medium,
  });

  static const MushafReaderSettings defaults = MushafReaderSettings();

  MushafReaderSettings copyWith({
    bool? tajweedEnabled,
    bool? naturalMaddEnabled,
    MushafThemeMode? themeMode,
    MushafLayoutMode? layoutMode,
    QuranFontScale? fontScale,
  }) {
    return MushafReaderSettings(
      tajweedEnabled: tajweedEnabled ?? this.tajweedEnabled,
      naturalMaddEnabled: naturalMaddEnabled ?? this.naturalMaddEnabled,
      themeMode: themeMode ?? this.themeMode,
      layoutMode: layoutMode ?? this.layoutMode,
      fontScale: fontScale ?? this.fontScale,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MushafReaderSettings &&
      other.tajweedEnabled == tajweedEnabled &&
      other.naturalMaddEnabled == naturalMaddEnabled &&
      other.themeMode == themeMode &&
      other.layoutMode == layoutMode &&
      other.fontScale == fontScale;

  @override
  int get hashCode => Object.hash(
    tajweedEnabled,
    naturalMaddEnabled,
    themeMode,
    layoutMode,
    fontScale,
  );
}
