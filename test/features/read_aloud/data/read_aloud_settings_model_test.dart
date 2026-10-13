import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/read_aloud/data/models/read_aloud_settings_model.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/read_aloud_settings.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_voice.dart';

void main() {
  test('round-trips every setting', () {
    const settings = ReadAloudSettings(
      rate: 1.25,
      pitch: 0.9,
      volume: 0.6,
      voice: SpeechVoiceRef(
        name: 'Majed',
        locale: 'ar-001',
        identifier: 'com.apple.voice.compact.ar-001.Maged',
      ),
      engine: 'com.google.android.tts',
      highlightWords: false,
      announceHeadings: false,
      readExplanation: false,
      autoContinue: true,
      partGap: SpeechPartGap.long,
    );

    final stored = ReadAloudSettingsModel.fromEntity(settings).encode();

    expect(ReadAloudSettingsModel.decode(stored).toEntity(), settings);
  });

  test('falls back to defaults for missing or mistyped fields', () {
    final settings =
        ReadAloudSettingsModel.decode(
          '{"rate": "fast", "partGap": "huge", "voice": {"name": ""}, '
          '"highlightWords": 1}',
        ).toEntity();

    expect(settings, ReadAloudSettings.defaults);
  });

  test('pulls stored values back into range', () {
    final settings =
        ReadAloudSettingsModel.decode('{"rate": 9, "volume": -1}').toEntity();

    expect(settings.rate, 1.5);
    expect(settings.volume, ReadAloudSettings.minVolume);
  });

  test('reads a JSON value that is not an object as defaults', () {
    expect(
      ReadAloudSettingsModel.decode('[1, 2]').toEntity(),
      ReadAloudSettings.defaults,
    );
  });
}
