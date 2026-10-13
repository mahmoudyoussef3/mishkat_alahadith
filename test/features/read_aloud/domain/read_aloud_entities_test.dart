import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/read_aloud_settings.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_engine.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_track.dart';

void main() {
  group('ReadAloudSettings', () {
    test('nextRate steps to the next faster speed', () {
      expect(const ReadAloudSettings(rate: 1.0).nextRate, 1.25);
    });

    test('nextRate wraps from the fastest to the slowest', () {
      expect(const ReadAloudSettings(rate: 1.5).nextRate, 0.5);
    });

    test('normalized pulls values back into range', () {
      final settings =
          const ReadAloudSettings(rate: 9, pitch: 0.1, volume: 0).normalized();

      expect(settings.rate, 1.5);
      expect(settings.pitch, ReadAloudSettings.minPitch);
      expect(settings.volume, ReadAloudSettings.minVolume);
    });

    test('soundsLike ignores options that do not change the voice', () {
      const settings = ReadAloudSettings();

      expect(
        settings.soundsLike(settings.copyWith(highlightWords: false)),
        isTrue,
      );
      expect(settings.soundsLike(settings.copyWith(rate: 1.25)), isFalse);
    });

    test('copyWith can clear the voice and engine', () {
      final settings = const ReadAloudSettings(
        engine: 'com.google.android.tts',
      ).copyWith(clearEngine: true);

      expect(settings.engine, isNull);
    });
  });

  group('SpeechRateRange', () {
    test('maps a speed through the platform normal rate', () {
      const range = SpeechRateRange(min: 0, normal: 0.5, max: 1.5);

      expect(range.rateFor(1.0), 0.5);
      expect(range.rateFor(1.5), 0.75);
    });

    test('keeps the rate within what the platform accepts', () {
      const range = SpeechRateRange(min: 0.1, normal: 0.5, max: 0.6);

      expect(range.rateFor(1.5), 0.6);
    });
  });

  group('SpeechTrack', () {
    final track = SpeechTrack(
      key: 'k',
      title: 't',
      segments: [
        SpeechSegment(part: SpeechPart.isnad, spoken: 'a' * 10),
        SpeechSegment(part: SpeechPart.matn, spoken: 'b' * 30),
      ],
    );

    test('progress counts the segments already read', () {
      expect(track.progressAt(1, 15), (10 + 15) / 40);
    });

    test('progress is complete past the last segment', () {
      expect(track.progressAt(2, 0), 1);
    });
  });

  group('SpeechSegment', () {
    test('has no range to highlight without a source', () {
      final segment = SpeechSegment(part: SpeechPart.heading, spoken: 'عنوان');

      expect(segment.sourceRange(0, 3), isNull);
    });

    test('reads a part only of the same text', () {
      final segment = SpeechSegment(
        part: SpeechPart.matn,
        source: 'نص',
        spoken: 'نص',
        sourceStarts: const [0, 1],
        sourceEnds: const [1, 2],
      );

      expect(segment.reads(SpeechPart.matn, text: 'نص'), isTrue);
      expect(segment.reads(SpeechPart.matn, text: 'نص آخر'), isFalse);
      expect(segment.reads(SpeechPart.isnad, text: 'نص'), isFalse);
    });
  });
}
