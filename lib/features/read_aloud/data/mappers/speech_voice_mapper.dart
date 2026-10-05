import '../../domain/entities/speech_voice.dart';

/// Converts between flutter_tts voice maps and [SpeechVoice].
///
/// Android reports `quality` (very low … very high), `network_required`
/// ("1"/"0") and tab-separated `features`; iOS reports `quality` (default,
/// enhanced, premium), `gender` and `identifier`.
abstract final class SpeechVoiceMapper {
  /// Android's flag for a voice whose data is not downloaded yet.
  static const _notInstalled = 'notInstalled';

  /// Null when the map lacks a name or locale.
  static SpeechVoice? fromPlatform(Map<String, String> map) {
    final name = map['name']?.trim() ?? '';
    final locale = map['locale']?.trim() ?? '';
    if (name.isEmpty || locale.isEmpty) return null;
    final identifier = map['identifier']?.trim();
    final features = (map['features'] ?? '').split('\t');

    return SpeechVoice(
      name: name,
      locale: locale,
      identifier: identifier == null || identifier.isEmpty ? null : identifier,
      quality: _quality(map['quality']),
      gender: switch (map['gender']?.toLowerCase()) {
        'male' => SpeechVoiceGender.male,
        'female' => SpeechVoiceGender.female,
        _ => SpeechVoiceGender.unspecified,
      },
      requiresNetwork: map['network_required'] == '1',
      installed: !features.contains(_notInstalled),
    );
  }

  static SpeechVoiceQuality _quality(String? value) =>
      switch (value?.toLowerCase()) {
        'very high' || 'premium' => SpeechVoiceQuality.veryHigh,
        'high' || 'enhanced' => SpeechVoiceQuality.high,
        'normal' || 'default' => SpeechVoiceQuality.normal,
        'low' => SpeechVoiceQuality.low,
        'very low' => SpeechVoiceQuality.veryLow,
        _ => SpeechVoiceQuality.unknown,
      };

  /// The map `setVoice` expects: Android matches name and locale, iOS
  /// prefers the identifier.
  static Map<String, String> toPlatform(SpeechVoice voice) => {
    'name': voice.name,
    'locale': voice.locale,
    if (voice.identifier != null) 'identifier': voice.identifier!,
  };
}
