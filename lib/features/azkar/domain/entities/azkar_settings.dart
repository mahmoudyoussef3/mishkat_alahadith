/// The language shown under the Arabic, if any.
///
/// Turkish is left out: the upstream `tr.json` is mostly translation-service
/// quota errors in place of text. Another language joins with its file in
/// `assets/azkar/` and a value here.
enum AzkarTranslation {
  none(null),
  english('en');

  const AzkarTranslation(this.languageCode);

  /// Null for [none].
  final String? languageCode;
}

/// How large the Arabic text is drawn, as a multiple of its designed size.
enum AzkarFontScale {
  small(0.88),
  medium(1.0),
  large(1.14),
  extraLarge(1.3);

  const AzkarFontScale(this.factor);

  final double factor;
}

/// How the reader likes to read and count.
class AzkarSettings {
  final AzkarTranslation translation;
  final AzkarFontScale fontScale;

  /// A light vibration with every count, and a stronger one on finishing.
  final bool hapticFeedback;

  /// Moves on to the next zikr once one is finished.
  final bool autoAdvance;

  const AzkarSettings({
    required this.translation,
    required this.fontScale,
    required this.hapticFeedback,
    required this.autoAdvance,
  });

  static const defaults = AzkarSettings(
    translation: AzkarTranslation.none,
    fontScale: AzkarFontScale.medium,
    hapticFeedback: true,
    autoAdvance: true,
  );

  AzkarSettings copyWith({
    AzkarTranslation? translation,
    AzkarFontScale? fontScale,
    bool? hapticFeedback,
    bool? autoAdvance,
  }) => AzkarSettings(
    translation: translation ?? this.translation,
    fontScale: fontScale ?? this.fontScale,
    hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    autoAdvance: autoAdvance ?? this.autoAdvance,
  );

  @override
  bool operator ==(Object other) =>
      other is AzkarSettings &&
      other.translation == translation &&
      other.fontScale == fontScale &&
      other.hapticFeedback == hapticFeedback &&
      other.autoAdvance == autoAdvance;

  @override
  int get hashCode =>
      Object.hash(translation, fontScale, hapticFeedback, autoAdvance);
}
