import 'dart:convert';

import '../../domain/entities/read_aloud_settings.dart';
import '../../domain/entities/speech_voice.dart';

/// [ReadAloudSettings] as stored: JSON, read tolerantly so a field that is
/// missing or of the wrong type falls back to its default.
class ReadAloudSettingsModel {
  final Map<String, Object?> json;

  const ReadAloudSettingsModel(this.json);

  factory ReadAloudSettingsModel.decode(String source) {
    final decoded = jsonDecode(source);
    return ReadAloudSettingsModel(
      decoded is Map<String, Object?> ? decoded : const {},
    );
  }

  factory ReadAloudSettingsModel.fromEntity(ReadAloudSettings settings) {
    final voice = settings.voice;
    return ReadAloudSettingsModel({
      'rate': settings.rate,
      'pitch': settings.pitch,
      'volume': settings.volume,
      if (voice != null)
        'voice': {
          'name': voice.name,
          'locale': voice.locale,
          if (voice.identifier != null) 'identifier': voice.identifier,
        },
      if (settings.engine != null) 'engine': settings.engine,
      'highlightWords': settings.highlightWords,
      'announceHeadings': settings.announceHeadings,
      'readExplanation': settings.readExplanation,
      'autoContinue': settings.autoContinue,
      'partGap': settings.partGap.name,
    });
  }

  String encode() => jsonEncode(json);

  ReadAloudSettings toEntity() {
    const defaults = ReadAloudSettings.defaults;
    double number(String key, double fallback) => switch (json[key]) {
      final num value when value.isFinite => value.toDouble(),
      _ => fallback,
    };
    bool flag(String key, bool fallback) => switch (json[key]) {
      final bool value => value,
      _ => fallback,
    };

    return ReadAloudSettings(
      rate: number('rate', defaults.rate),
      pitch: number('pitch', defaults.pitch),
      volume: number('volume', defaults.volume),
      voice: _voice(json['voice']),
      engine: switch (json['engine']) {
        final String value when value.isNotEmpty => value,
        _ => null,
      },
      highlightWords: flag('highlightWords', defaults.highlightWords),
      announceHeadings: flag('announceHeadings', defaults.announceHeadings),
      readExplanation: flag('readExplanation', defaults.readExplanation),
      autoContinue: flag('autoContinue', defaults.autoContinue),
      partGap:
          SpeechPartGap.values.asNameMap()[json['partGap']] ?? defaults.partGap,
    ).normalized();
  }

  static SpeechVoiceRef? _voice(Object? value) {
    if (value is! Map) return null;
    final name = value['name'];
    final locale = value['locale'];
    if (name is! String || name.isEmpty || locale is! String) return null;
    final identifier = value['identifier'];
    return SpeechVoiceRef(
      name: name,
      locale: locale,
      identifier:
          identifier is String && identifier.isNotEmpty ? identifier : null,
    );
  }
}
