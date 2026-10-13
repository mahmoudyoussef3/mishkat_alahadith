import 'speech_voice.dart';

/// The speech rates a platform accepts. Android and iOS use different
/// scales, so a reading speed is mapped through [normal].
class SpeechRateRange {
  final double min;
  final double normal;
  final double max;

  const SpeechRateRange({
    required this.min,
    required this.normal,
    required this.max,
  });

  /// flutter_tts maps both platforms so that 0.5 is normal speech.
  static const SpeechRateRange fallback = SpeechRateRange(
    min: 0,
    normal: 0.5,
    max: 1,
  );

  /// The platform rate for a speed of [multiplier] × normal.
  double rateFor(double multiplier) =>
      (normal * multiplier).clamp(min, max).toDouble();
}

/// What the device's speech engine offers, as the platform reports it.
class SpeechEngineSnapshot {
  /// Languages the engine can speak, as BCP-47 tags.
  final List<String> languages;
  final List<SpeechVoice> voices;

  /// The engine's own default voice (Android); null elsewhere.
  final SpeechVoice? defaultVoice;

  /// Installed speech engines (Android); empty elsewhere.
  final List<String> engines;
  final String? defaultEngine;

  /// The engine in use; null for the system default.
  final String? currentEngine;
  final SpeechRateRange rateRange;

  /// Longest text the engine accepts in one go (Android); null when
  /// unlimited.
  final int? maxInputLength;

  const SpeechEngineSnapshot({
    this.languages = const [],
    this.voices = const [],
    this.defaultVoice,
    this.engines = const [],
    this.defaultEngine,
    this.currentEngine,
    this.rateRange = SpeechRateRange.fallback,
    this.maxInputLength,
  });
}

/// The Arabic reading the engine can give, decided from a
/// [SpeechEngineSnapshot] and the reader's settings.
class SpeechEngineReport {
  /// The Arabic locale to read in; null when the engine has none.
  final String? locale;

  /// Arabic voices, best first.
  final List<SpeechVoice> voices;

  /// The voice automatic selection reads with.
  final SpeechVoice? autoVoice;

  /// The voice that will actually read: the chosen one when it is usable,
  /// otherwise [autoVoice].
  final SpeechVoice? voice;

  /// Arabic locales whose voice data is not downloaded (Android).
  final Set<String> missingLocales;
  final List<String> engines;
  final String? defaultEngine;
  final String? currentEngine;

  /// The chosen engine could not start; the system default reads instead.
  final bool chosenEngineFailed;
  final SpeechRateRange rateRange;
  final int? maxInputLength;

  const SpeechEngineReport({
    this.locale,
    this.voices = const [],
    this.autoVoice,
    this.voice,
    this.missingLocales = const {},
    this.engines = const [],
    this.defaultEngine,
    this.currentEngine,
    this.chosenEngineFailed = false,
    this.rateRange = SpeechRateRange.fallback,
    this.maxInputLength,
  });

  bool get arabicAvailable => locale != null;

  /// Reading needs a connection: the voice is server-side or its data is
  /// missing.
  bool get needsNetwork {
    final voice = this.voice;
    if (voice != null) return voice.requiresNetwork || !voice.installed;
    final locale = this.locale;
    return locale != null && missingLocales.contains(locale);
  }

  /// Engines to choose between; worth showing only when there are several.
  bool get canChooseEngine => engines.length > 1;
}

/// The voice and sound to apply to the engine before reading.
class SpeechVoiceSetup {
  final String locale;

  /// Null leaves the engine on its default voice for [locale].
  final SpeechVoice? voice;

  /// Platform rate, already mapped through [SpeechRateRange].
  final double rate;
  final double pitch;
  final double volume;

  const SpeechVoiceSetup({
    required this.locale,
    required this.voice,
    required this.rate,
    required this.pitch,
    required this.volume,
  });
}
