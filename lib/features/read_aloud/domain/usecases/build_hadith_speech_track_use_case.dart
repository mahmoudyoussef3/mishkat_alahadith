import 'package:mishkat_almasabih/core/helpers/hadith_text.dart';

import '../entities/hadith_speech_request.dart';
import '../entities/read_aloud_settings.dart';
import '../entities/speech_track.dart';
import '../services/spoken_arabic.dart';

/// Lays a hadith page out as the utterances that read it, in order.
///
/// The hadith is split into its chain and words the same way the reading
/// card shows it, so each utterance maps onto the text on screen.
class BuildHadithSpeechTrackUseCase {
  const BuildHadithSpeechTrackUseCase();

  /// Longest stretch read in one utterance. Well under every engine's cap,
  /// and short enough that skipping moves by about a sentence.
  static const int maxSegmentLength = 600;

  SpeechTrack call(HadithSpeechRequest request, ReadAloudSettings settings) {
    final segments = <SpeechSegment>[];
    final announce = settings.announceHeadings;

    switch (request) {
      case BookHadithSpeech():
        if (announce) {
          _heading(
            segments,
            [
              request.bookName.trim(),
              if (request.number.trim().isNotEmpty)
                'الحديث رقم ${request.number.trim()}',
            ].where((part) => part.isNotEmpty).join('، '),
          );
        }
        _hadith(segments, request.text);

      case ExplainedHadithSpeech(:final hadith):
        _hadith(segments, hadith.hadeeth ?? '');
        final attribution = hadith.attribution?.trim() ?? '';
        if (attribution.isNotEmpty) {
          _read(segments, SpeechPart.source, attribution);
        }
        if (!settings.readExplanation) break;

        final explanation = hadith.explanation?.trim() ?? '';
        if (explanation.isNotEmpty) {
          if (announce) _heading(segments, 'الشرح');
          _read(segments, SpeechPart.explanation, explanation);
        }

        final lessons = [
          for (final hint in hadith.hints ?? const <String>[])
            if (hint.trim().isNotEmpty) hint.trim(),
        ];
        if (lessons.isNotEmpty) {
          if (announce) _heading(segments, 'من فوائد الحديث');
          for (var i = 0; i < lessons.length; i++) {
            _readWhole(segments, SpeechPart.lesson, i, lessons[i]);
          }
        }

        final meanings = [
          for (final meaning in hadith.wordsMeanings ?? const [])
            if ((meaning.word ?? '').trim().isNotEmpty)
              [
                meaning.word!.trim(),
                if ((meaning.meaning ?? '').trim().isNotEmpty)
                  meaning.meaning!.trim(),
              ].join(': '),
        ];
        if (meanings.isNotEmpty) {
          if (announce) _heading(segments, 'معاني الكلمات');
          for (var i = 0; i < meanings.length; i++) {
            _readWhole(segments, SpeechPart.wordMeaning, i, meanings[i]);
          }
        }
    }

    return SpeechTrack(
      key: request.key,
      title: request.title,
      segments: segments,
    );
  }

  void _hadith(List<SpeechSegment> segments, String text) {
    if (text.trim().isEmpty) return;
    final parts = HadithTextParts.split(text);
    final isnad = parts.isnad;
    if (isnad != null) _read(segments, SpeechPart.isnad, isnad);
    _read(segments, SpeechPart.matn, parts.matn);
  }

  /// Reads [source] in chunks, each mapped back onto it word by word.
  void _read(List<SpeechSegment> segments, SpeechPart part, String source) {
    for (final range in SpokenArabic.chunks(
      source,
      maxLength: maxSegmentLength,
    )) {
      final spoken = SpokenArabic.from(
        source,
        start: range.start,
        end: range.end,
      );
      if (spoken.isEmpty) continue;
      segments.add(
        SpeechSegment(
          part: part,
          source: source,
          spoken: spoken.text,
          sourceStarts: spoken.sourceStarts,
          sourceEnds: spoken.sourceEnds,
        ),
      );
    }
  }

  /// Reads [text] as item [item] of [part], highlighted as a whole.
  void _readWhole(
    List<SpeechSegment> segments,
    SpeechPart part,
    int item,
    String text,
  ) {
    for (final range in SpokenArabic.chunks(
      text,
      maxLength: maxSegmentLength,
    )) {
      final spoken = SpokenArabic.from(
        text,
        start: range.start,
        end: range.end,
      );
      if (spoken.isEmpty) continue;
      segments.add(SpeechSegment(part: part, item: item, spoken: spoken.text));
    }
  }

  void _heading(List<SpeechSegment> segments, String text) {
    final spoken = SpokenArabic.from(text);
    if (spoken.isEmpty) return;
    segments.add(SpeechSegment(part: SpeechPart.heading, spoken: spoken.text));
  }
}
