import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/read_aloud/data/datasources/read_aloud_settings_local_datasource.dart';
import 'package:mishkat_almasabih/features/read_aloud/data/datasources/text_to_speech_datasource.dart';
import 'package:mishkat_almasabih/features/read_aloud/data/repos/read_aloud_repo_impl.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/read_aloud_settings.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_engine.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_event.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_voice.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records engine calls in order.
class _FakeTts implements TextToSpeechDataSource {
  final calls = <String>[];
  bool voiceAccepted = true;
  bool languageAccepted = true;
  bool speakAccepted = true;
  bool resumeAccepted = true;
  bool throwOnSpeak = false;

  @override
  Stream<SpeechEvent> get events => const Stream.empty();

  @override
  String? get currentEngine => null;

  @override
  Future<void> configure() async => calls.add('configure');

  @override
  Future<List<String>> languages() async => ['ar', 'en-US'];

  @override
  Future<List<Map<String, String>>> voices() async => [
    {'name': 'ar-xa-x-arc-local', 'locale': 'ar', 'quality': 'high'},
    {'locale': 'ar'},
  ];

  @override
  Future<Map<String, String>?> defaultVoice() async => null;

  @override
  Future<List<String>> engines() async => const [];

  @override
  Future<String?> defaultEngine() async => null;

  @override
  Future<bool> useEngine(String? engine) async {
    calls.add('useEngine:$engine');
    return true;
  }

  @override
  Future<SpeechRateValidRange?> rateRange() async =>
      SpeechRateValidRange(0, 0.5, 1.5, TextToSpeechPlatform.android);

  @override
  Future<int?> maxInputLength() async => 4000;

  @override
  Future<bool> isLanguageAvailable(String locale) async => true;

  @override
  Future<Map<String, bool>> areLanguagesInstalled(List<String> locales) async =>
      const {};

  @override
  Future<bool> setLanguage(String locale) async {
    calls.add('setLanguage:$locale');
    return languageAccepted;
  }

  @override
  Future<bool> setVoice(Map<String, String> voice) async {
    calls.add('setVoice:${voice['name']}');
    return voiceAccepted;
  }

  @override
  Future<void> clearVoice() async => calls.add('clearVoice');

  @override
  Future<void> setSpeechRate(double rate) async => calls.add('rate:$rate');

  @override
  Future<void> setPitch(double pitch) async => calls.add('pitch:$pitch');

  @override
  Future<void> setVolume(double volume) async => calls.add('volume:$volume');

  @override
  Future<bool> speak(String text) async {
    if (throwOnSpeak) throw PlatformException(code: 'tts');
    calls.add('speak:$text');
    return speakAccepted;
  }

  @override
  Future<bool> resume() async => resumeAccepted;

  @override
  Future<bool> pause() async => true;

  @override
  Future<void> stop({bool release = false}) async => calls.add('stop:$release');

  @override
  Future<String> synthesizeToFile(String text, String name) async =>
      '/tmp/$name.wav';
}

class _BrokenStorage implements ReadAloudSettingsLocalDataSource {
  @override
  Future<String?> getSettings() async => throw Exception('storage');

  @override
  Future<void> saveSettings(String settings) async =>
      throw Exception('storage');
}

const _voice = SpeechVoice(name: 'ar-xa-x-arc-local', locale: 'ar');

SpeechVoiceSetup _setup({SpeechVoice? voice = _voice}) => SpeechVoiceSetup(
  locale: 'ar',
  voice: voice,
  rate: 0.5,
  pitch: 1,
  volume: 0.8,
);

void main() {
  late _FakeTts tts;
  late ReadAloudRepoImpl repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tts = _FakeTts();
    repo = ReadAloudRepoImpl(tts, ReadAloudSettingsLocalDataSource());
  });

  group('settings', () {
    test('are the defaults when nothing was saved', () async {
      final result = await repo.getSettings();

      expect((result as ApiSuccess).data, ReadAloudSettings.defaults);
    });

    test('are read back after saving', () async {
      const saved = ReadAloudSettings(rate: 1.25, autoContinue: true);
      await repo.saveSettings(saved);

      final fresh = ReadAloudRepoImpl(tts, ReadAloudSettingsLocalDataSource());

      expect((await fresh.getSettings() as ApiSuccess).data, saved);
    });

    test('announce a change', () async {
      final changes = <ReadAloudSettings>[];
      repo.settingsChanges.listen(changes.add);

      await repo.saveSettings(const ReadAloudSettings(rate: 0.75));
      await Future<void>.delayed(Duration.zero);

      expect(changes, [const ReadAloudSettings(rate: 0.75)]);
    });

    test('do not announce saving the same values again', () async {
      await repo.saveSettings(const ReadAloudSettings(rate: 0.75));
      final changes = <ReadAloudSettings>[];
      repo.settingsChanges.listen(changes.add);

      await repo.saveSettings(const ReadAloudSettings(rate: 0.75));
      await Future<void>.delayed(Duration.zero);

      expect(changes, isEmpty);
    });

    test('fall back to defaults when the stored value is unreadable', () async {
      SharedPreferences.setMockInitialValues({'read_aloud_settings': '{oops'});

      final result = await repo.getSettings();

      expect((result as ApiSuccess).data, ReadAloudSettings.defaults);
    });

    test('map a storage error to CacheFailure', () async {
      final broken = ReadAloudRepoImpl(tts, _BrokenStorage());

      final result = await broken.getSettings();

      expect((result as ApiFailure).failure, isA<CacheFailure>());
    });

    test('are kept for the session when saving fails', () async {
      final broken = ReadAloudRepoImpl(tts, _BrokenStorage());
      const settings = ReadAloudSettings(rate: 1.5);

      final saved = await broken.saveSettings(settings);

      expect((saved as ApiFailure).failure, isA<CacheFailure>());
      expect((await broken.getSettings() as ApiSuccess).data, settings);
    });
  });

  group('applyVoice', () {
    test('sets the language before the voice, then the sound', () async {
      await repo.applyVoice(_setup());

      expect(tts.calls, [
        'configure',
        'setLanguage:ar',
        'setVoice:ar-xa-x-arc-local',
        'rate:0.5',
        'pitch:1.0',
        'volume:0.8',
      ]);
    });

    test(
      'falls back to the Arabic default voice when the voice is refused',
      () async {
        tts.voiceAccepted = false;

        await repo.applyVoice(_setup());

        expect(tts.calls.sublist(2, 5), [
          'setVoice:ar-xa-x-arc-local',
          'clearVoice',
          'setLanguage:ar',
        ]);
      },
    );

    test('fails when Arabic cannot be set without a voice', () async {
      tts.languageAccepted = false;

      final result = await repo.applyVoice(_setup(voice: null));

      expect((result as ApiFailure).failure, isA<SpeechFailure>());
    });
  });

  group('engine', () {
    test('inspection maps voices and the speed range', () async {
      final result = await repo.inspectEngine(engine: 'com.x');
      final snapshot = (result as ApiSuccess<SpeechEngineSnapshot>).data;

      expect(tts.calls, contains('useEngine:com.x'));
      expect(snapshot.voices.single.quality, SpeechVoiceQuality.high);
      expect(snapshot.rateRange.max, 1.5);
      expect(snapshot.maxInputLength, 4000);
    });

    test('speaking fails when the engine refuses', () async {
      tts.speakAccepted = false;

      final result = await repo.speak('نص');

      expect((result as ApiFailure).failure, isA<SpeechFailure>());
    });

    test('speaking maps a platform error to SpeechFailure', () async {
      tts.throwOnSpeak = true;

      final result = await repo.speak('نص');

      expect((result as ApiFailure).failure, isA<SpeechFailure>());
    });

    test('resuming fails when nothing was paused', () async {
      tts.resumeAccepted = false;

      expect(await repo.resume(), isA<ApiFailure<void>>());
    });

    test('stopping can release the audio session', () async {
      await repo.stop(release: true);

      expect(tts.calls, ['stop:true']);
    });
  });
}
