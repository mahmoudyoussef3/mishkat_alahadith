import '../entities/speech_voice.dart';

/// Chooses which Arabic voice reads hadiths.
abstract final class ArabicVoicePicker {
  /// Modern Standard Arabic first, as hadiths are in fusha, then the
  /// locales engines most often voice it under.
  static const List<String> _preferredLocales = [
    'ar-001',
    'ar',
    'ar-sa',
    'ar-xa',
    'ar-ae',
    'ar-eg',
  ];

  static int _localeRank(String locale) {
    final index = _preferredLocales.indexOf(
      SpeechVoice.normalizeLocale(locale),
    );
    return index == -1 ? _preferredLocales.length : index;
  }

  /// The Arabic ones among [locales], each once, preferred first.
  static List<String> arabicLocales(Iterable<String> locales) {
    final seen = <String>{};
    final arabic = [
      for (final locale in locales)
        if (SpeechVoice.languageOf(locale) == 'ar' &&
            seen.add(SpeechVoice.normalizeLocale(locale)))
          locale,
    ];
    arabic.sort((a, b) {
      final byRank = _localeRank(a).compareTo(_localeRank(b));
      return byRank != 0 ? byRank : a.compareTo(b);
    });
    return arabic;
  }

  /// The Arabic voices among [voices], best first: ready to use, then
  /// offline, then by quality, then the engine's own default, then by
  /// locale. Voices in [missingLocales] are marked not installed.
  static List<SpeechVoice> rank(
    Iterable<SpeechVoice> voices, {
    Set<String> missingLocales = const {},
    SpeechVoice? engineDefault,
  }) {
    final missing = {
      for (final locale in missingLocales) SpeechVoice.normalizeLocale(locale),
    };
    final arabic = [
      for (final voice in voices)
        if (voice.isArabic)
          missing.contains(SpeechVoice.normalizeLocale(voice.locale))
              ? SpeechVoice(
                name: voice.name,
                locale: voice.locale,
                identifier: voice.identifier,
                quality: voice.quality,
                gender: voice.gender,
                requiresNetwork: voice.requiresNetwork,
                installed: false,
              )
              : voice,
    ];

    int compare(SpeechVoice a, SpeechVoice b) {
      int prefer(bool x, bool y) => x == y ? 0 : (x ? -1 : 1);
      return [
        prefer(a.isReady, b.isReady),
        prefer(!a.requiresNetwork, !b.requiresNetwork),
        b.quality.rank.compareTo(a.quality.rank),
        prefer(a == engineDefault, b == engineDefault),
        _localeRank(a.locale).compareTo(_localeRank(b.locale)),
        a.name.compareTo(b.name),
      ].firstWhere((order) => order != 0, orElse: () => 0);
    }

    return arabic..sort(compare);
  }

  /// The best ready voice of a [rank]ed list.
  static SpeechVoice? best(List<SpeechVoice> ranked) {
    for (final voice in ranked) {
      if (voice.isReady) return voice;
    }
    return null;
  }

  /// The ready voice [ref] points to, or null.
  static SpeechVoice? find(List<SpeechVoice> ranked, SpeechVoiceRef? ref) {
    if (ref == null) return null;
    for (final voice in ranked) {
      if (voice.isReady && voice.matches(ref)) return voice;
    }
    return null;
  }
}
