import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/hadith_speech_request.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_engine.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_track.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/build_hadith_speech_track_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/export_hadith_audio_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/inspect_speech_engine_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/prepare_speech_use_case.dart';

import '../read_aloud_fakes.dart';

T _data<T>(ApiResult<T> result) => (result as ApiSuccess<T>).data;

Failure _failure(ApiResult<Object?> result) => (result as ApiFailure).failure;

void main() {
  late FakeReadAloudRepo repo;
  late InspectSpeechEngineUseCase inspect;
  late PrepareSpeechUseCase prepare;

  setUp(() {
    repo = FakeReadAloudRepo();
    inspect = InspectSpeechEngineUseCase(repo);
    prepare = PrepareSpeechUseCase(repo, inspect);
  });

  group('InspectSpeechEngineUseCase', () {
    test('reports no Arabic when the engine has none', () async {
      repo.snapshot = englishOnlyEngine;

      final report = _data(await inspect(quietSettings));

      expect(report.arabicAvailable, isFalse);
    });

    test('lists only Arabic voices, best first', () async {
      final report = _data(await inspect(quietSettings));

      expect(report.voices, [arabicVoice, secondArabicVoice]);
    });

    test('reads with the best voice when none was chosen', () async {
      final report = _data(await inspect(quietSettings));

      expect(report.voice, arabicVoice);
      expect(report.locale, 'ar');
    });

    test('reads with the chosen voice', () async {
      final report = _data(
        await inspect(quietSettings.copyWith(voice: secondArabicVoice.ref)),
      );

      expect(report.voice, secondArabicVoice);
    });

    test('falls back to the best voice when the chosen one is gone', () async {
      final report = _data(
        await inspect(quietSettings.copyWith(voice: englishVoice.ref)),
      );

      expect(report.voice, arabicVoice);
    });

    test('flags reading that needs a connection', () async {
      repo.installed = {'ar': false};

      final report = _data(await inspect(quietSettings));

      expect(report.voice, isNull);
      expect(report.needsNetwork, isTrue);
    });

    test('without a voice, trusts the engine on the language', () async {
      repo.snapshot = const SpeechEngineSnapshot(languages: ['ar']);
      repo.languageAvailable = false;

      final report = _data(await inspect(quietSettings));

      expect(report.arabicAvailable, isFalse);
    });

    test('inspects the chosen engine', () async {
      await inspect(quietSettings.copyWith(engine: 'com.google.android.tts'));

      expect(repo.inspectedEngine, 'com.google.android.tts');
    });
  });

  group('PrepareSpeechUseCase', () {
    test('applies the voice and sound, mapping the speed', () async {
      await prepare(quietSettings.copyWith(rate: 1.5, pitch: 1.2, volume: 0.6));

      final setup = repo.applied.single;
      expect(setup.locale, 'ar');
      expect(setup.voice, arabicVoice);
      expect(setup.rate, 0.75);
      expect(setup.pitch, 1.2);
      expect(setup.volume, 0.6);
    });

    test('fails clearly when there is no Arabic voice', () async {
      repo.snapshot = englishOnlyEngine;

      final result = await prepare(quietSettings);

      expect(_failure(result), isA<ArabicVoiceUnavailableFailure>());
      expect(repo.applied, isEmpty);
    });

    test('passes on a failure to apply the voice', () async {
      repo.failApply = true;

      expect(_failure(await prepare(quietSettings)), isA<SpeechFailure>());
    });
  });

  group('ExportHadithAudioUseCase', () {
    late ExportHadithAudioUseCase export;

    setUp(() {
      export = ExportHadithAudioUseCase(
        repo,
        prepare,
        const BuildHadithSpeechTrackUseCase(),
      );
    });

    test('records the hadith as one text, parts joined', () async {
      final result = await export(bookHadith, quietSettings);

      expect(_data(result), '/tmp/hadith.wav');
      expect(repo.synthesized.single, '$isnadText $matnText');
    });

    test('leaves the explanation out of the recording', () async {
      await export(
        const ExplainedHadithSpeech(
          title: 't',
          hadith: ExplainedHadith(
            hadeeth: 'إنما الأعمال بالنيات',
            attribution: 'متفق عليه',
            explanation: 'شرح طويل',
          ),
        ),
        quietSettings,
      );

      expect(repo.synthesized.single, 'إنما الأعمال بالنيات. متفق عليه');
    });

    test('refuses a text longer than the engine takes', () async {
      repo.snapshot = const SpeechEngineSnapshot(
        languages: ['ar'],
        voices: [arabicVoice],
        maxInputLength: 10,
      );

      final failure = _failure(await export(bookHadith, quietSettings));

      expect(failure.message, FailureMessages.speechTooLong);
      expect(repo.synthesized, isEmpty);
    });

    test('names the file after the reading', () {
      expect(
        ExportHadithAudioUseCase.fileNameFor(bookHadith),
        'hadith_book_bukhari_1',
      );
    });

    test('adds a sentence break only where a part does not end one', () {
      final text = ExportHadithAudioUseCase.joinSegments([
        SpeechSegment(part: SpeechPart.heading, spoken: 'العنوان'),
        SpeechSegment(part: SpeechPart.isnad, spoken: 'قال:'),
        SpeechSegment(part: SpeechPart.matn, spoken: 'الحديث'),
      ]);

      expect(text, 'العنوان. قال: الحديث');
    });
  });
}
