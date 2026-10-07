import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/read_aloud/data/mappers/speech_voice_mapper.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_voice.dart';

void main() {
  test('reads an Android voice', () {
    final voice =
        SpeechVoiceMapper.fromPlatform({
          'name': 'ar-xa-x-arz-network',
          'locale': 'ar',
          'quality': 'very high',
          'latency': 'normal',
          'network_required': '1',
          'features': 'networkTimeoutMs\tnetworkRetriesCount',
        })!;

    expect(voice.quality, SpeechVoiceQuality.veryHigh);
    expect(voice.requiresNetwork, isTrue);
    expect(voice.installed, isTrue);
  });

  test('reads Android\'s not-installed flag', () {
    final voice =
        SpeechVoiceMapper.fromPlatform({
          'name': 'ar-xa-x-arc-local',
          'locale': 'ar',
          'features': 'embeddedTts\tnotInstalled',
        })!;

    expect(voice.installed, isFalse);
  });

  test('reads an iOS voice', () {
    final voice =
        SpeechVoiceMapper.fromPlatform({
          'name': 'Majed',
          'locale': 'ar-001',
          'quality': 'premium',
          'gender': 'male',
          'identifier': 'com.apple.voice.premium.ar-001.Majed',
        })!;

    expect(voice.quality, SpeechVoiceQuality.veryHigh);
    expect(voice.gender, SpeechVoiceGender.male);
    expect(voice.identifier, 'com.apple.voice.premium.ar-001.Majed');
  });

  test('skips a voice without a name or locale', () {
    expect(SpeechVoiceMapper.fromPlatform({'locale': 'ar'}), isNull);
    expect(SpeechVoiceMapper.fromPlatform({'name': 'x'}), isNull);
  });

  test('writes the keys setVoice matches on', () {
    const voice = SpeechVoice(
      name: 'Majed',
      locale: 'ar-001',
      identifier: 'com.apple.voice.compact.ar-001.Maged',
    );

    expect(SpeechVoiceMapper.toPlatform(voice), {
      'name': 'Majed',
      'locale': 'ar-001',
      'identifier': 'com.apple.voice.compact.ar-001.Maged',
    });
  });
}
