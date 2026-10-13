/// How natural a voice sounds, from the engine's own rating.
///
/// iOS rates voices default, enhanced or premium; Android from very low to
/// very high. Both are folded onto one scale so voices can be compared.
enum SpeechVoiceQuality {
  unknown,
  veryLow,
  low,
  normal,
  high,
  veryHigh;

  /// Higher is better; [unknown] ranks with [low].
  int get rank => switch (this) {
    SpeechVoiceQuality.veryLow => 0,
    SpeechVoiceQuality.unknown || SpeechVoiceQuality.low => 1,
    SpeechVoiceQuality.normal => 2,
    SpeechVoiceQuality.high => 3,
    SpeechVoiceQuality.veryHigh => 4,
  };
}

enum SpeechVoiceGender { unspecified, male, female }

/// Enough to find a voice again after the app restarts.
class SpeechVoiceRef {
  final String name;
  final String locale;

  /// iOS's stable voice id; null on Android.
  final String? identifier;

  const SpeechVoiceRef({
    required this.name,
    required this.locale,
    this.identifier,
  });

  @override
  bool operator ==(Object other) =>
      other is SpeechVoiceRef &&
      other.name == name &&
      other.locale == locale &&
      other.identifier == identifier;

  @override
  int get hashCode => Object.hash(name, locale, identifier);
}

/// A voice the device's speech engine can read with.
class SpeechVoice {
  final String name;

  /// BCP-47 tag as the engine reports it, e.g. «ar-SA» or «ar-001».
  final String locale;
  final String? identifier;
  final SpeechVoiceQuality quality;
  final SpeechVoiceGender gender;

  /// Synthesised on a server: needs a connection and starts more slowly.
  final bool requiresNetwork;

  /// False when the engine lists the voice but its data is not downloaded.
  final bool installed;

  const SpeechVoice({
    required this.name,
    required this.locale,
    this.identifier,
    this.quality = SpeechVoiceQuality.unknown,
    this.gender = SpeechVoiceGender.unspecified,
    this.requiresNetwork = false,
    this.installed = true,
  });

  SpeechVoiceRef get ref =>
      SpeechVoiceRef(name: name, locale: locale, identifier: identifier);

  /// The language part of [locale], lower-cased: «ar» for «ar_SA».
  String get language => languageOf(locale);

  bool get isArabic => language == 'ar';

  /// Usable right now, without downloading anything first.
  bool get isReady => installed;

  bool matches(SpeechVoiceRef ref) {
    final id = ref.identifier;
    if (id != null && id.isNotEmpty && identifier != null) {
      return identifier == id;
    }
    return name == ref.name && sameLocale(locale, ref.locale);
  }

  static String normalizeLocale(String locale) =>
      locale.trim().replaceAll('_', '-').toLowerCase();

  static String languageOf(String locale) =>
      normalizeLocale(locale).split('-').first;

  static bool sameLocale(String a, String b) =>
      normalizeLocale(a) == normalizeLocale(b);

  @override
  bool operator ==(Object other) =>
      other is SpeechVoice &&
      other.name == name &&
      other.locale == locale &&
      other.identifier == identifier;

  @override
  int get hashCode => Object.hash(name, locale, identifier);
}
