enum MushafThemeMode {
  /// Follows the app's light/dark theme.
  system,

  /// Cream paper and dark ink, as printed.
  day,

  /// Dark paper for reading at night.
  night,
}

class MushafReaderSettings {
  /// On by default; the reading settings can still switch it off.
  final bool tajweedEnabled;

  /// The natural madd is by far the most frequent rule, so colouring it tints
  /// most of the page — it gets its own switch, off by default.
  final bool naturalMaddEnabled;
  final MushafThemeMode themeMode;

  const MushafReaderSettings({
    this.tajweedEnabled = true,
    this.naturalMaddEnabled = false,
    this.themeMode = MushafThemeMode.system,
  });

  static const MushafReaderSettings defaults = MushafReaderSettings();

  MushafReaderSettings copyWith({
    bool? tajweedEnabled,
    bool? naturalMaddEnabled,
    MushafThemeMode? themeMode,
  }) {
    return MushafReaderSettings(
      tajweedEnabled: tajweedEnabled ?? this.tajweedEnabled,
      naturalMaddEnabled: naturalMaddEnabled ?? this.naturalMaddEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is MushafReaderSettings &&
      other.tajweedEnabled == tajweedEnabled &&
      other.naturalMaddEnabled == naturalMaddEnabled &&
      other.themeMode == themeMode;

  @override
  int get hashCode =>
      Object.hash(tajweedEnabled, naturalMaddEnabled, themeMode);
}
