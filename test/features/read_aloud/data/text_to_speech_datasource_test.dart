import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:mishkat_almasabih/core/errors/exceptions.dart';
import 'package:mishkat_almasabih/features/read_aloud/data/datasources/text_to_speech_datasource.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_event.dart';

/// flutter_tts with its platform calls recorded instead of made.
class _FakeFlutterTts extends FlutterTts {
  final calls = <String>[];

  @override
  Future<dynamic> awaitSpeakCompletion(bool awaitCompletion) async {
    calls.add('awaitSpeakCompletion:$awaitCompletion');
    return 1;
  }

  @override
  Future<dynamic> awaitSynthCompletion(bool awaitCompletion) async {
    calls.add('awaitSynthCompletion:$awaitCompletion');
    return 1;
  }

  @override
  Future<dynamic> stop() async {
    calls.add('stop');
    return 1;
  }

  @override
  Future<dynamic> speak(String text, {bool focus = false}) async {
    calls.add('speak:$text:$focus');
    return 1;
  }

  /// Engines that fail to start.
  final brokenEngines = <String>{};

  /// What a recording answers; never completing by default, like Android
  /// after a failed recording.
  Completer<dynamic> synthesis = Completer<dynamic>();

  /// Completes when a recording reaches the engine.
  final synthesisStarted = Completer<void>();

  @override
  Future<dynamic> setEngine(String engine) async {
    calls.add('setEngine:$engine');
    if (brokenEngines.contains(engine)) {
      throw PlatformException(code: 'TtsError');
    }
    return 1;
  }

  @override
  Future<dynamic> get getDefaultEngine async => 'com.google.android.tts';

  @override
  Future<dynamic> synthesizeToFile(
    String text,
    String fileName, [
    bool isFullPath = false,
  ]) {
    calls.add('synthesizeToFile');
    synthesisStarted.complete();
    return synthesis.future;
  }

  @override
  Future<dynamic> setIosAudioCategory(
    IosTextToSpeechAudioCategory category,
    List<IosTextToSpeechAudioCategoryOptions> options, [
    IosTextToSpeechAudioMode mode = IosTextToSpeechAudioMode.defaultMode,
  ]) async {
    calls.add(
      'iosCategory:${category.name}:${options.map((o) => o.name).join(',')}:${mode.name}',
    );
    return 1;
  }

  @override
  Future<dynamic> autoStopSharedSession(bool autoStop) async {
    calls.add('autoStopSharedSession:$autoStop');
    return 1;
  }

  @override
  Future<dynamic> get getLanguages async => ['ar', null, '', 'en-US'];

  @override
  Future<dynamic> get getVoices async => [
    {'name': 'ar-xa-x-arc-local', 'locale': 'ar'},
    'not a voice',
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeFlutterTts tts;
  late TextToSpeechDataSource source;

  setUp(() {
    tts = _FakeFlutterTts();
    source = TextToSpeechDataSource(tts: tts, platform: TargetPlatform.linux);
  });

  test('reports the engine callbacks as speech events', () async {
    final events = <SpeechEvent>[];
    source.events.listen(events.add);

    tts.startHandler!();
    tts.progressHandler!('إنما الأعمال', 5, 12, 'الأعمال');
    tts.pauseHandler!();
    tts.continueHandler!();
    tts.cancelHandler!();
    tts.completionHandler!();
    tts.errorHandler!('synthesis failed');
    await Future<void>.delayed(Duration.zero);

    expect(events, [
      isA<SpeechStarted>(),
      isA<SpeechProgress>()
          .having((e) => e.text, 'text', 'إنما الأعمال')
          .having((e) => e.start, 'start', 5)
          .having((e) => e.end, 'end', 12),
      isA<SpeechPaused>(),
      isA<SpeechResumed>(),
      isA<SpeechCancelled>(),
      isA<SpeechCompleted>(),
      isA<SpeechFailed>().having(
        (e) => e.message,
        'message',
        'synthesis failed',
      ),
    ]);
  });

  test('sets up completion handling once', () async {
    await source.configure();
    await source.configure();

    expect(tts.calls, [
      'awaitSpeakCompletion:false',
      'awaitSynthCompletion:true',
    ]);
  });

  test('clears a paused utterance before speaking a new one', () async {
    await source.speak('نص');

    expect(tts.calls, ['stop', 'speak:نص:true']);
  });

  test(
    'resumes by speaking the same utterance again, without stopping',
    () async {
      await source.speak('نص');
      tts.calls.clear();

      expect(await source.resume(), isTrue);
      expect(tts.calls, ['speak:نص:true']);
    },
  );

  test('has nothing to resume before anything was spoken', () async {
    expect(await source.resume(), isFalse);
    expect(tts.calls, isEmpty);
  });

  test('skips empty language entries', () async {
    expect(await source.languages(), ['ar', 'en-US']);
  });

  test('skips voice entries that are not maps', () async {
    expect(await source.voices(), [
      {'name': 'ar-xa-x-arc-local', 'locale': 'ar'},
    ]);
  });

  test('reports no installation state off Android', () async {
    expect(await source.areLanguagesInstalled(['ar']), isEmpty);
  });

  group('on Android', () {
    setUp(() {
      source = TextToSpeechDataSource(
        tts: tts,
        platform: TargetPlatform.android,
      );
    });

    test('stops the speech in progress before switching engines', () async {
      await source.useEngine('com.samsung.SMT');

      expect(tts.calls, ['stop', 'setEngine:com.samsung.SMT']);
    });

    test('falls back to the default when an engine cannot start', () async {
      tts.brokenEngines.add('com.broken');

      expect(await source.useEngine('com.broken'), isFalse);
      expect(source.currentEngine, isNull);
      expect(tts.calls.last, 'setEngine:com.google.android.tts');
    });

    test('does not try an engine that failed again', () async {
      tts.brokenEngines.add('com.broken');
      await source.useEngine('com.broken');
      tts.calls.clear();

      expect(await source.useEngine('com.broken'), isFalse);
      expect(tts.calls, isEmpty);
    });
  });

  test('a recording the engine reports failed ends at once', () async {
    final directory = await Directory.systemTemp.createTemp('tts_test');
    addTearDown(() => directory.delete(recursive: true));
    source = TextToSpeechDataSource(
      tts: tts,
      platform: TargetPlatform.android,
      temporaryDirectory: () async => directory,
    );

    final recording = source.synthesizeToFile('نص', 'hadith');
    await tts.synthesisStarted.future;
    tts.errorHandler!('Error from TextToSpeech (synth)');

    await expectLater(recording, throwsA(isA<TextToSpeechException>()));
  });

  test('events of a recording are not reported as a reading', () async {
    final directory = await Directory.systemTemp.createTemp('tts_test');
    addTearDown(() => directory.delete(recursive: true));
    source = TextToSpeechDataSource(
      tts: tts,
      platform: TargetPlatform.android,
      temporaryDirectory: () async => directory,
    );
    final events = <SpeechEvent>[];
    source.events.listen(events.add);

    final recording = source.synthesizeToFile('نص', 'hadith');
    await tts.synthesisStarted.future;
    tts.startHandler!();
    tts.errorHandler!('failed');
    await expectLater(recording, throwsA(isA<TextToSpeechException>()));
    await Future<void>.delayed(Duration.zero);

    expect(events, isEmpty);
  });

  test('on iOS lowers other audio while reading, without pumping', () async {
    source = TextToSpeechDataSource(tts: tts, platform: TargetPlatform.iOS);

    await source.configure();

    expect(tts.calls, [
      'awaitSpeakCompletion:false',
      'awaitSynthCompletion:true',
      'iosCategory:playback:duckOthers:spokenAudio',
      'autoStopSharedSession:false',
    ]);
  });
}
