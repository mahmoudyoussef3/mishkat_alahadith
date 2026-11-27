import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_text.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/hadith_speech_request.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/read_aloud_settings.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/entities/speech_track.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/usecases/build_hadith_speech_track_use_case.dart';

const _bookText =
    'حدثنا عبد الله بن مسلمة عن مالك قال: '
    '«إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى»';

const _book = BookHadithSpeech(
  title: 'صحيح البخاري · حديث ١',
  text: _bookText,
  bookName: 'صحيح البخاري',
  bookSlug: 'bukhari',
  number: '1',
);

const _explained = ExplainedHadithSpeech(
  title: 'إنما الأعمال بالنيات',
  hadith: ExplainedHadith(
    id: '5',
    hadeeth: '«إنما الأعمال بالنيات»',
    attribution: 'متفق عليه',
    explanation: 'يبين الحديث أن الأعمال بمقاصدها.',
    hints: ['فائدة أولى', '  ', 'فائدة ثانية'],
    wordsMeanings: [
      HadithWordMeaning(word: 'النيات', meaning: 'جمع نية'),
      HadithWordMeaning(word: ' '),
    ],
  ),
);

const _build = BuildHadithSpeechTrackUseCase();

List<SpeechPart> _parts(SpeechTrack track) => [
  for (final segment in track.segments) segment.part,
];

void main() {
  group('a book hadith', () {
    test('reads its number, then its chain, then its words', () {
      final track = _build(_book, const ReadAloudSettings());

      expect(_parts(track), [
        SpeechPart.heading,
        SpeechPart.isnad,
        SpeechPart.matn,
      ]);
      expect(track.segments.first.spoken, 'صحيح البخاري، الحديث رقم 1');
    });

    test('leaves the number out when headings are off', () {
      final track = _build(
        _book,
        const ReadAloudSettings(announceHeadings: false),
      );

      expect(_parts(track), [SpeechPart.isnad, SpeechPart.matn]);
    });

    test('reads from the same text the reading card shows', () {
      final parts = HadithTextParts.split(_bookText);
      final track = _build(_book, const ReadAloudSettings());

      expect(track.segments[1].source, parts.isnad);
      expect(track.segments[2].source, parts.matn);
    });

    test('maps a spoken word onto the words on screen', () {
      final matn = _build(_book, const ReadAloudSettings()).segments[2];
      final start = matn.spoken.indexOf('الأعمال');
      final range = matn.sourceRange(start, start + 'الأعمال'.length)!;

      expect(matn.source!.substring(range.start, range.end), 'الأعمال');
    });

    test('is keyed by book and number', () {
      expect(_build(_book, const ReadAloudSettings()).key, 'book:bukhari:1');
    });
  });

  group('an explained hadith', () {
    test('reads the hadith, source, explanation, lessons and words', () {
      final track = _build(_explained, const ReadAloudSettings());

      expect(_parts(track), [
        SpeechPart.matn,
        SpeechPart.source,
        SpeechPart.heading,
        SpeechPart.explanation,
        SpeechPart.heading,
        SpeechPart.lesson,
        SpeechPart.lesson,
        SpeechPart.heading,
        SpeechPart.wordMeaning,
      ]);
    });

    test('numbers lessons as the list shows them, skipping blanks', () {
      final lessons = _build(
        _explained,
        const ReadAloudSettings(),
      ).segments.where((s) => s.part == SpeechPart.lesson);

      expect([for (final s in lessons) s.item], [0, 1]);
      expect(lessons.last.spoken, 'فائدة ثانية');
    });

    test('reads a word with its meaning', () {
      final word = _build(_explained, const ReadAloudSettings()).segments.last;

      expect(word.spoken, 'النيات: جمع نية');
    });

    test('stops after the source when the explanation is off', () {
      final track = _build(
        _explained,
        const ReadAloudSettings(readExplanation: false),
      );

      expect(_parts(track), [SpeechPart.matn, SpeechPart.source]);
    });

    test('splits a long explanation into parts of one source', () {
      final long = List.filled(60, 'هذه جملة من شرح الحديث الشريف.').join(' ');
      final track = _build(
        ExplainedHadithSpeech(
          title: 't',
          hadith: ExplainedHadith(hadeeth: 'نص', explanation: long),
        ),
        const ReadAloudSettings(announceHeadings: false),
      );
      final explanation = [
        for (final s in track.segments)
          if (s.part == SpeechPart.explanation) s,
      ];

      expect(explanation.length, greaterThan(1));
      expect(explanation.every((s) => s.source == long), isTrue);
      expect(
        explanation.every(
          (s) =>
              s.spoken.length <= BuildHadithSpeechTrackUseCase.maxSegmentLength,
        ),
        isTrue,
      );
    });
  });

  test('reads nothing for a hadith without text', () {
    final track = _build(
      const BookHadithSpeech(
        title: '',
        text: '  ',
        bookName: '',
        bookSlug: 'b',
        number: '',
      ),
      const ReadAloudSettings(),
    );

    expect(track.isEmpty, isTrue);
  });
}
