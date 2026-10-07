import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/hadith_speech_request.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/read_aloud_settings.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_event.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/build_hadith_speech_track_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/export_hadith_audio_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/get_read_aloud_settings_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/inspect_speech_engine_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/pause_speech_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/prepare_speech_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/resume_speech_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/speak_text_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/stop_speech_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/watch_read_aloud_settings_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/watch_speech_events_use_case.dart';
import 'package:mishkat_almasabih/features/read_aloud/presentation/logic/read_aloud_cubit.dart';

import '../read_aloud_fakes.dart';

ReadAloudCubit _cubitFor(FakeReadAloudRepo repo) {
  final prepare = PrepareSpeechUseCase(repo, InspectSpeechEngineUseCase(repo));
  return ReadAloudCubit(
    const BuildHadithSpeechTrackUseCase(),
    prepare,
    GetReadAloudSettingsUseCase(repo),
    WatchReadAloudSettingsUseCase(repo),
    WatchSpeechEventsUseCase(repo),
    SpeakTextUseCase(repo),
    PauseSpeechUseCase(repo),
    ResumeSpeechUseCase(repo),
    StopSpeechUseCase(repo),
    ExportHadithAudioUseCase(
      repo,
      prepare,
      const BuildHadithSpeechTrackUseCase(),
    ),
  );
}

/// Lets queued engine calls and timers of zero length run.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

/// The engine reports reaching [word] of [utterance].
SpeechProgress _reached(String utterance, String word) {
  final start = utterance.indexOf(word);
  return SpeechProgress(
    text: utterance,
    start: start,
    end: start + word.length,
  );
}

void main() {
  late FakeReadAloudRepo repo;
  late ReadAloudCubit cubit;
  final owner = Object();

  setUp(() {
    repo = FakeReadAloudRepo();
    cubit = _cubitFor(repo);
  });

  tearDown(() => cubit.close());

  /// Starts reading the book hadith and has the engine start the chain.
  Future<void> startReading() async {
    await cubit.play(owner, bookHadith);
    repo.emit(const SpeechStarted());
  }

  group('play', () {
    test('sets the voice up, then reads the first part', () async {
      await cubit.play(owner, bookHadith);

      expect(repo.applied, hasLength(1));
      expect(repo.spoken, [isnadText]);
      expect(cubit.state.status, ReadAloudStatus.playing);
      expect(cubit.state.ownedBy(owner), isTrue);
    });

    test('tells the reader when there is no Arabic voice', () async {
      repo.snapshot = englishOnlyEngine;

      await cubit.play(owner, bookHadith);

      expect(repo.spoken, isEmpty);
      expect(cubit.state.status, ReadAloudStatus.idle);
      expect(
        cubit.state.notice?.message,
        const ArabicVoiceUnavailableFailure().message,
      );
      expect(cubit.state.notice?.owner, same(owner));
    });

    test('resumes rather than restarts the reading it paused', () async {
      await startReading();
      await cubit.pause();

      await cubit.play(owner, bookHadith);

      expect(repo.resumes, 1);
      expect(repo.spoken, hasLength(1));
    });

    test('sets the voice up only once for unchanged settings', () async {
      await startReading();
      repo.emit(const SpeechCompleted());
      await _settle();

      expect(repo.applied, hasLength(1));
    });
  });

  group('moving through the parts', () {
    test('a finished part moves on to the next', () async {
      await startReading();

      repo.emit(const SpeechCompleted());
      await _settle();

      expect(cubit.state.index, 1);
      expect(repo.spoken.last, matnText);
    });

    test('a completion before the part has started is ignored', () async {
      await cubit.play(owner, bookHadith);

      repo.emit(const SpeechCompleted());
      await _settle();

      expect(cubit.state.index, 0);
      expect(repo.spoken, hasLength(1));
    });

    test('finishing the last part completes and releases audio', () async {
      await startReading();
      repo.emit(const SpeechCompleted());
      await _settle();
      repo.emit(const SpeechStarted());

      repo.emit(const SpeechCompleted());
      await _settle();

      expect(cubit.state.status, ReadAloudStatus.completed);
      expect(cubit.state.progress, 1);
      expect(repo.stops.last, isTrue);
    });

    test('next reads the following part', () async {
      await startReading();

      await cubit.next();

      expect(cubit.state.index, 1);
      expect(repo.spoken.last, matnText);
    });

    test('a completion arriving after next does not skip again', () async {
      await startReading();

      final skipping = cubit.next();
      repo.emit(const SpeechCompleted());
      await skipping;
      await _settle();

      expect(cubit.state.index, 1);
      expect(repo.spoken, [isnadText, matnText]);
    });

    test('previous restarts the part once some of it was read', () async {
      await startReading();
      repo.emit(_reached(isnadText, 'مسلمة'));

      await cubit.previous();

      expect(cubit.state.index, 0);
      expect(repo.spoken, [isnadText, isnadText]);
    });

    test('restart reads a completed reading again from the start', () async {
      await startReading();
      await cubit.next();
      repo.emit(const SpeechStarted());
      repo.emit(const SpeechCompleted());
      await _settle();

      await cubit.restart();

      expect(cubit.state.index, 0);
      expect(cubit.state.status, ReadAloudStatus.playing);
      expect(repo.spoken.last, isnadText);
    });
  });

  group('following the words', () {
    test('marks the word being read on the text on screen', () async {
      await startReading();

      repo.emit(_reached(isnadText, 'مسلمة'));

      final segment = cubit.state.segment!;
      final word = cubit.state.word!;
      expect(segment.source!.substring(word.start, word.end), 'مسلمة');
    });

    test('maps positions in the rest of a part after a pause', () async {
      await startReading();
      final rest = isnadText.substring(isnadText.indexOf('مسلمة'));

      repo.emit(_reached(rest, 'مالك'));

      final word = cubit.state.word!;
      expect(
        cubit.state.segment!.source!.substring(word.start, word.end),
        'مالك',
      );
      expect(cubit.state.spokenOffset, isnadText.indexOf('مالك'));
    });

    test('ignores positions in another utterance', () async {
      await startReading();

      repo.emit(_reached('نص آخر تماماً', 'آخر'));

      expect(cubit.state.word, isNull);
    });
  });

  group('pause and resume', () {
    test('pause pauses the engine and resume carries on natively', () async {
      await startReading();

      await cubit.pause();
      expect(cubit.state.status, ReadAloudStatus.paused);
      expect(repo.pauses, 1);

      await cubit.resume();
      expect(cubit.state.status, ReadAloudStatus.playing);
      expect(repo.resumes, 1);
      expect(repo.spoken, hasLength(1));
    });

    test('an engine that cannot pause restarts from the last word', () async {
      repo.canPause = false;
      await startReading();
      repo.emit(_reached(isnadText, 'مسلمة'));

      await cubit.pause();
      await cubit.resume();

      expect(repo.stops, contains(false));
      expect(repo.resumes, 0);
      expect(repo.spoken.last, isnadText.substring(isnadText.indexOf('مسلمة')));
    });

    test('pausing before the engine started stops it instead', () async {
      await cubit.play(owner, bookHadith);

      await cubit.pause();

      expect(repo.pauses, 0);
      expect(repo.stops.last, isFalse);
    });

    test('an engine error pauses the reading with a message', () async {
      await startReading();

      repo.emit(const SpeechFailed('synthesis failed'));

      expect(cubit.state.status, ReadAloudStatus.paused);
      expect(cubit.state.notice?.message, const SpeechFailure().message);
    });

    test('a failed start pauses with a message, ready to retry', () async {
      await startReading();
      repo.failSpeak = true;

      await cubit.next();

      expect(cubit.state.status, ReadAloudStatus.paused);
      expect(cubit.state.notice, isNotNull);
    });
  });

  group('ownership', () {
    test('the owner closing its screen stops the reading', () async {
      await startReading();

      await cubit.release(owner);

      expect(cubit.state.status, ReadAloudStatus.idle);
      expect(repo.stops.last, isTrue);
    });

    test('another screen closing leaves the reading alone', () async {
      await startReading();

      await cubit.release(Object());

      expect(cubit.state.status, ReadAloudStatus.playing);
    });

    test('the owner being covered pauses the reading', () async {
      await startReading();

      await cubit.interrupt(owner);

      expect(cubit.state.status, ReadAloudStatus.paused);
    });

    test('another screen starting a reading takes it over', () async {
      final other = Object();
      await startReading();

      await cubit.play(other, bookHadith);

      expect(cubit.state.ownedBy(other), isTrue);
      expect(repo.spoken, [isnadText, isnadText]);
    });
  });

  group('settings', () {
    test('a voice change is heard from the current word', () async {
      await startReading();
      repo.emit(_reached(isnadText, 'مسلمة'));

      await repo.saveSettings(quietSettings.copyWith(rate: 1.25));
      await _settle();

      expect(repo.applied, hasLength(2));
      expect(repo.applied.last.rate, 0.625);
      expect(repo.spoken.last, isnadText.substring(isnadText.indexOf('مسلمة')));
    });

    test('a change that does not alter the voice keeps reading', () async {
      await startReading();

      await repo.saveSettings(quietSettings.copyWith(highlightWords: false));
      await _settle();

      expect(repo.applied, hasLength(1));
      expect(repo.spoken, hasLength(1));
    });

    testWidgets('the chosen pause is left between different parts', (
      tester,
    ) async {
      repo.settings = quietSettings.copyWith(partGap: SpeechPartGap.medium);
      final paced = _cubitFor(repo);
      addTearDown(paced.close);
      await paced.play(owner, bookHadith);
      repo.emit(const SpeechStarted());

      repo.emit(const SpeechCompleted());
      await tester.pump();
      expect(repo.spoken, hasLength(1));

      await tester.pump(SpeechPartGap.medium.duration);
      expect(repo.spoken.last, matnText);
    });
  });

  group('preview', () {
    test('pauses the reading and plays a sample', () async {
      await startReading();

      await cubit.preview(owner: owner);

      expect(cubit.state.status, ReadAloudStatus.paused);
      expect(cubit.state.previewing, isTrue);
      expect(repo.spoken.last, ReadAloudCubit.previewText);
    });

    test('ends when the sample finishes, leaving the reading paused', () async {
      await startReading();
      await cubit.preview(owner: owner);
      repo.emit(const SpeechStarted());

      repo.emit(const SpeechCompleted());

      expect(cubit.state.previewing, isFalse);
      expect(cubit.state.status, ReadAloudStatus.paused);
      expect(cubit.state.index, 0);
    });

    test('resuming after a sample reads the part again', () async {
      await startReading();
      await cubit.preview(owner: owner);
      repo.emit(const SpeechStarted());
      repo.emit(const SpeechCompleted());

      await cubit.resume();

      expect(repo.resumes, 0);
      expect(repo.spoken.last, isnadText);
    });
  });

  group('export', () {
    test('pauses the reading and records the hadith', () async {
      await startReading();

      final result = await cubit.exportAudio(bookHadith);

      expect((result as ApiSuccess<String>).data, '/tmp/hadith.wav');
      expect(cubit.state.status, ReadAloudStatus.paused);
      expect(cubit.state.exporting, isFalse);
      expect(repo.synthesized.single, contains('الأعمال'));
    });

    test('passes a recording failure on', () async {
      repo.synthesis = const ApiResult.failure(SpeechFailure());

      final result = await cubit.exportAudio(bookHadith);

      expect(result, isA<ApiFailure<String>>());
    });
  });

  group('getting ready', () {
    test('closing the screen while the engine gets ready stops it', () async {
      final starting = cubit.play(owner, bookHadith);
      final releasing = cubit.release(owner);
      await starting;
      await releasing;

      expect(cubit.state.status, ReadAloudStatus.idle);
      expect(repo.spoken, isEmpty);
    });

    test(
      'stopping while the old reading is being stopped is not undone',
      () async {
        await startReading();
        repo.stopGate = Completer<void>();
        final starting = cubit.play(Object(), bookHadith);
        await _settle();

        final stopping = cubit.stop();
        repo.stopGate!.complete();
        await starting;
        await stopping;

        expect(cubit.state.status, ReadAloudStatus.idle);
        expect(repo.spoken, [isnadText]);
      },
    );

    test(
      'a new reading paused while the voice is set up starts at its start',
      () async {
        const otherHadith = BookHadithSpeech(
          title: 'صحيح البخاري · حديث ٢',
          text: '$isnadText «$matnText»',
          bookName: 'صحيح البخاري',
          bookSlug: 'bukhari',
          number: '2',
        );
        await startReading();
        repo.emit(_reached(isnadText, 'مسلمة'));
        await cubit.pause();
        await repo.saveSettings(quietSettings.copyWith(rate: 1.25));
        repo.applyGate = Completer<void>();
        final starting = cubit.play(owner, otherHadith);
        await _settle();

        final pausing = cubit.pause();
        repo.applyGate!.complete();
        await starting;
        await pausing;
        await cubit.resume();

        expect(repo.spoken.last, isnadText);
      },
    );
  });

  group('interruptions', () {
    test('the system pausing the utterance pauses the reading', () async {
      await startReading();

      repo.emit(const SpeechPaused());
      await cubit.resume();

      expect(repo.resumes, 1);
      expect(cubit.state.status, ReadAloudStatus.playing);
    });

    test(
      'the system dropping the utterance pauses, to restart from the word',
      () async {
        await startReading();
        repo.emit(_reached(isnadText, 'مسلمة'));

        repo.emit(const SpeechCancelled());
        expect(cubit.state.status, ReadAloudStatus.paused);
        await cubit.resume();

        expect(repo.resumes, 0);
        expect(
          repo.spoken.last,
          isnadText.substring(isnadText.indexOf('مسلمة')),
        );
      },
    );

    test('a failure of an utterance already left behind is ignored', () async {
      await startReading();

      repo.emit(const SpeechCompleted());
      repo.emit(const SpeechFailed('late'));
      await _settle();

      expect(cubit.state.notice, isNull);
      expect(repo.spoken.last, matnText);
    });
  });

  group('chapter reading', () {
    const nextHadith = BookHadithSpeech(
      title: 'صحيح البخاري · حديث ٢',
      text: '$isnadText «$matnText»',
      bookName: 'صحيح البخاري',
      bookSlug: 'bukhari',
      number: '2',
    );

    Future<void> finishReading() async {
      await startReading();
      await cubit.next();
      repo.emit(const SpeechStarted());
      repo.emit(const SpeechCompleted());
      await _settle();
    }

    test('finishing with next hadith on asks for the next hadith', () async {
      repo.settings = quietSettings.copyWith(autoContinue: true);

      await finishReading();

      expect(cubit.state.continueToNext, isTrue);
    });

    test('finishing with next hadith off does not', () async {
      await finishReading();

      expect(cubit.state.continueToNext, isFalse);
    });

    test('the screen moving on while reading reads the new hadith', () async {
      await startReading();

      await cubit.follow(owner, nextHadith);

      expect(cubit.state.track?.key, nextHadith.key);
      expect(cubit.state.isPlaying, isTrue);
    });

    test(
      'the screen moving on after asking for it reads the new hadith',
      () async {
        repo.settings = quietSettings.copyWith(autoContinue: true);
        await finishReading();

        await cubit.follow(owner, nextHadith);

        expect(cubit.state.track?.key, nextHadith.key);
      },
    );

    test('the screen moving on from a paused reading ends it', () async {
      await startReading();
      await cubit.pause();

      await cubit.follow(owner, nextHadith);

      expect(cubit.state.status, ReadAloudStatus.idle);
    });

    test('another screen moving on leaves the reading alone', () async {
      await startReading();

      await cubit.follow(Object(), nextHadith);

      expect(cubit.state.track?.key, bookHadith.key);
    });
  });

  group('review fixes', () {
    test('previous at the very start restarts the first part', () async {
      await startReading();
      repo.emit(_reached(isnadText, 'عبد'));

      await cubit.previous();

      expect(repo.spoken, [isnadText, isnadText]);
    });

    test('a speed change re-applies the sound without re-inspecting', () async {
      await startReading();

      await repo.saveSettings(quietSettings.copyWith(rate: 1.25));
      await _settle();

      expect(repo.inspections, 1);
      expect(repo.applied, hasLength(2));
    });

    test('a voice change inspects the engine again', () async {
      await startReading();

      await repo.saveSettings(
        quietSettings.copyWith(voice: secondArabicVoice.ref),
      );
      await _settle();

      expect(repo.inspections, 2);
      expect(repo.applied.last.voice, secondArabicVoice);
    });

    test('recording ends a voice sample', () async {
      await cubit.preview(owner: owner);

      await cubit.exportAudio(bookHadith);

      expect(cubit.state.previewing, isFalse);
    });

    test('a sample with no reading under it hands the audio back', () async {
      await cubit.preview(owner: owner);
      repo.emit(const SpeechStarted());

      repo.emit(const SpeechCompleted());
      await _settle();

      expect(repo.stops.last, isTrue);
    });
  });
}
