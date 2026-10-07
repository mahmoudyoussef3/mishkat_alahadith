import 'dart:async';

import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/hadith_speech_request.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/read_aloud_settings.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_engine.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_event.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_voice.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/repos/read_aloud_repo.dart';

const arabicVoice = SpeechVoice(
  name: 'ar-xa-x-arc-local',
  locale: 'ar',
  quality: SpeechVoiceQuality.high,
);

const secondArabicVoice = SpeechVoice(
  name: 'ar-xa-x-ard-local',
  locale: 'ar',
  quality: SpeechVoiceQuality.normal,
);

const englishVoice = SpeechVoice(
  name: 'en-us-x-sfg-local',
  locale: 'en-US',
  quality: SpeechVoiceQuality.veryHigh,
);

const arabicEngine = SpeechEngineSnapshot(
  languages: ['ar', 'en-US'],
  voices: [secondArabicVoice, arabicVoice, englishVoice],
  rateRange: SpeechRateRange(min: 0, normal: 0.5, max: 1.5),
  maxInputLength: 4000,
);

const englishOnlyEngine = SpeechEngineSnapshot(
  languages: ['en-US'],
  voices: [englishVoice],
);

const isnadText = 'حدثنا عبد الله بن مسلمة عن مالك قال:';
const matnText = 'إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى';

/// Reads as two parts, chain then words, when headings are off.
const bookHadith = BookHadithSpeech(
  title: 'صحيح البخاري · حديث ١',
  text: '$isnadText «$matnText»',
  bookName: 'صحيح البخاري',
  bookSlug: 'bukhari',
  number: '1',
);

/// Settings that keep tests to the hadith's own parts, with no pauses.
const quietSettings = ReadAloudSettings(
  announceHeadings: false,
  partGap: SpeechPartGap.none,
);

/// An engine that records what it is asked and reports what tests emit.
class FakeReadAloudRepo implements ReadAloudRepo {
  ReadAloudSettings settings = quietSettings;
  SpeechEngineSnapshot snapshot = arabicEngine;
  Map<String, bool> installed = const {};
  bool languageAvailable = true;
  bool canPause = true;
  bool failSpeak = false;
  bool failApply = false;
  ApiResult<String> synthesis = const ApiResult.success('/tmp/hadith.wav');

  final StreamController<ReadAloudSettings> _settingsChanges =
      StreamController<ReadAloudSettings>.broadcast(sync: true);
  final StreamController<SpeechEvent> _events =
      StreamController<SpeechEvent>.broadcast(sync: true);

  final spoken = <String>[];
  final applied = <SpeechVoiceSetup>[];

  /// The `release` flag of each stop.
  final stops = <bool>[];
  final synthesized = <String>[];
  int pauses = 0;
  int resumes = 0;
  int inspections = 0;
  String? inspectedEngine;

  /// While set, stopping or applying a voice waits for it, like an engine
  /// that is slow to answer.
  Completer<void>? stopGate;
  Completer<void>? applyGate;

  void emit(SpeechEvent event) => _events.add(event);

  @override
  Future<ApiResult<ReadAloudSettings>> getSettings() async =>
      ApiResult.success(settings);

  @override
  Future<ApiResult<void>> saveSettings(ReadAloudSettings settings) async {
    this.settings = settings;
    _settingsChanges.add(settings);
    return const ApiResult.success(null);
  }

  @override
  Stream<ReadAloudSettings> get settingsChanges => _settingsChanges.stream;

  @override
  Stream<SpeechEvent> get speechEvents => _events.stream;

  @override
  Future<ApiResult<SpeechEngineSnapshot>> inspectEngine({
    String? engine,
  }) async {
    inspections++;
    inspectedEngine = engine;
    return ApiResult.success(snapshot);
  }

  @override
  Future<ApiResult<bool>> isLanguageAvailable(String locale) async =>
      ApiResult.success(languageAvailable);

  @override
  Future<ApiResult<Map<String, bool>>> areLanguagesInstalled(
    List<String> locales,
  ) async => ApiResult.success(installed);

  @override
  Future<ApiResult<void>> applyVoice(SpeechVoiceSetup setup) async {
    applied.add(setup);
    await applyGate?.future;
    return failApply
        ? const ApiResult.failure(SpeechFailure())
        : const ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> speak(String text) async {
    spoken.add(text);
    return failSpeak
        ? const ApiResult.failure(SpeechFailure())
        : const ApiResult.success(null);
  }

  @override
  Future<ApiResult<bool>> pause() async {
    pauses++;
    return ApiResult.success(canPause);
  }

  @override
  Future<ApiResult<void>> resume() async {
    resumes++;
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> stop({bool release = false}) async {
    stops.add(release);
    await stopGate?.future;
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<String>> synthesizeToFile(
    String text, {
    required String name,
  }) async {
    synthesized.add(text);
    return synthesis;
  }
}
