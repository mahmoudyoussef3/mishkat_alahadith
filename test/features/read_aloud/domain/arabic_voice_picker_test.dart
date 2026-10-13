import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_voice.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/services/arabic_voice_picker.dart';

const _network = SpeechVoice(
  name: 'ar-xa-x-arz-network',
  locale: 'ar',
  quality: SpeechVoiceQuality.veryHigh,
  requiresNetwork: true,
);
const _localHigh = SpeechVoice(
  name: 'ar-xa-x-arc-local',
  locale: 'ar',
  quality: SpeechVoiceQuality.high,
);
const _localNormal = SpeechVoice(
  name: 'ar-xa-x-ard-local',
  locale: 'ar',
  quality: SpeechVoiceQuality.normal,
);
const _notInstalled = SpeechVoice(
  name: 'ar-eg-premium',
  locale: 'ar-EG',
  quality: SpeechVoiceQuality.veryHigh,
  installed: false,
);
const _english = SpeechVoice(
  name: 'en-us-x-sfg-local',
  locale: 'en-US',
  quality: SpeechVoiceQuality.veryHigh,
);

void main() {
  group('arabicLocales', () {
    test('keeps Arabic locales once each, Modern Standard Arabic first', () {
      expect(
        ArabicVoicePicker.arabicLocales([
          'en-US',
          'ar-SA',
          'ar',
          'ar-001',
          'ar_EG',
          'AR-SA',
        ]),
        ['ar-001', 'ar', 'ar-SA', 'ar_EG'],
      );
    });

    test('is empty when the engine has no Arabic', () {
      expect(ArabicVoicePicker.arabicLocales(['en-US', 'fr-FR']), isEmpty);
    });
  });

  group('rank', () {
    test('lists only Arabic voices', () {
      final ranked = ArabicVoicePicker.rank([_english, _localHigh]);

      expect(ranked, [_localHigh]);
    });

    test('puts installed, offline and better voices first', () {
      final ranked = ArabicVoicePicker.rank([
        _notInstalled,
        _network,
        _localNormal,
        _localHigh,
      ]);

      expect(ranked, [_localHigh, _localNormal, _network, _notInstalled]);
    });

    test('marks voices of a missing locale as not installed', () {
      final ranked = ArabicVoicePicker.rank(
        [_localHigh],
        missingLocales: {'AR'},
      );

      expect(ranked.single.installed, isFalse);
    });

    test('prefers the engine default between otherwise equal voices', () {
      const a = SpeechVoice(name: 'a', locale: 'ar');
      const b = SpeechVoice(name: 'b', locale: 'ar');

      expect(ArabicVoicePicker.rank([a, b], engineDefault: b).first, b);
    });
  });

  group('best and find', () {
    test('best is the first ready voice', () {
      final ranked = ArabicVoicePicker.rank([_notInstalled, _localNormal]);

      expect(ArabicVoicePicker.best(ranked), _localNormal);
    });

    test('best is null when no voice is ready', () {
      expect(ArabicVoicePicker.best([_notInstalled]), isNull);
    });

    test('find returns the chosen voice', () {
      final ranked = ArabicVoicePicker.rank([_localHigh, _localNormal]);

      expect(ArabicVoicePicker.find(ranked, _localNormal.ref), _localNormal);
    });

    test('find matches an iOS voice by identifier', () {
      const majed = SpeechVoice(
        name: 'Majed',
        locale: 'ar-001',
        identifier: 'com.apple.voice.compact.ar-001.Maged',
      );
      const renamed = SpeechVoiceRef(
        name: 'Majed (Enhanced)',
        locale: 'ar-001',
        identifier: 'com.apple.voice.compact.ar-001.Maged',
      );

      expect(ArabicVoicePicker.find([majed], renamed), majed);
    });

    test('find ignores a chosen voice that is not installed', () {
      expect(
        ArabicVoicePicker.find([_notInstalled], _notInstalled.ref),
        isNull,
      );
    });
  });
}
