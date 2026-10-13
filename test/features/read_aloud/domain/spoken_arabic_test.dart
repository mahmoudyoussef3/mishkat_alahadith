import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/read_aloud/domain/services/spoken_arabic.dart';

/// The source text a spoken word was read from.
String _sourceOf(String source, SpokenText spoken, String word) {
  final start = spoken.text.indexOf(word);
  expect(start, isNot(-1), reason: '«$word» is not in «${spoken.text}»');
  final end = start + word.length;
  return source.substring(
    spoken.sourceStarts[start],
    spoken.sourceEnds[end - 1],
  );
}

void main() {
  group('SpokenArabic.from', () {
    test('drops quotes and keeps the words between them apart', () {
      final spoken = SpokenArabic.from('قال:«إنما الأعمال»');

      expect(spoken.text, 'قال: إنما الأعمال');
    });

    test('maps each spoken word back onto the source', () {
      const source = 'قال: «إنما الأعمال بالنيات»';
      final spoken = SpokenArabic.from(source);

      expect(_sourceOf(source, spoken, 'الأعمال'), 'الأعمال');
      expect(_sourceOf(source, spoken, 'بالنيات'), 'بالنيات');
    });

    test('writes ﷺ out and maps the words onto the ligature', () {
      const source = 'النبي ﷺ قال';
      final spoken = SpokenArabic.from(source);

      expect(spoken.text, 'النبي صلى الله عليه وسلم قال');
      expect(_sourceOf(source, spoken, 'عليه'), 'ﷺ');
      expect(_sourceOf(source, spoken, 'قال'), 'قال');
    });

    test('writes out a bracketed honorific abbreviation', () {
      final spoken = SpokenArabic.from('النبي(ص) قال');

      expect(spoken.text, 'النبي صلى الله عليه وسلم قال');
    });

    test('removes tatweel inside a word', () {
      const source = 'الـلـه';
      final spoken = SpokenArabic.from(source);

      expect(spoken.text, 'الله');
      expect(_sourceOf(source, spoken, 'الله'), source);
    });

    test('drops direction marks without splitting the word', () {
      final spoken = SpokenArabic.from('‏حدثنا‏ مالك');

      expect(spoken.text, 'حدثنا مالك');
    });

    test('keeps harakat for pronunciation', () {
      final spoken = SpokenArabic.from('إِنَّمَا');

      expect(spoken.text, 'إِنَّمَا');
    });

    test('collapses spaces and trims both ends', () {
      final spoken = SpokenArabic.from('   قال    رسول  الله  ');

      expect(spoken.text, 'قال رسول الله');
    });

    test('keeps one line break where lines break', () {
      final spoken = SpokenArabic.from('السطر الأول\n\n  السطر الثاني');

      expect(spoken.text, 'السطر الأول\nالسطر الثاني');
    });

    test('reads only the requested slice, mapped to absolute offsets', () {
      const source = 'الأول الثاني الثالث';
      final spoken = SpokenArabic.from(source, start: 6, end: 12);

      expect(spoken.text, 'الثاني');
      expect(spoken.sourceStarts.first, 6);
      expect(spoken.sourceEnds.last, 12);
    });

    test('is empty for text with nothing to say', () {
      expect(SpokenArabic.from(' «» ').isEmpty, isTrue);
    });
  });

  group('SpokenArabic.chunks', () {
    test('keeps a short text whole', () {
      expect(SpokenArabic.chunks('نص قصير'), [(start: 0, end: 7)]);
    });

    test('cuts after the last sentence that fits', () {
      final text = '${'أ' * 30}. ${'ب' * 30}. ${'ج' * 30}';

      expect(SpokenArabic.chunks(text, maxLength: 70), [
        (start: 0, end: 63),
        (start: 64, end: 94),
      ]);
    });

    test('cuts after a clause when no sentence ends in reach', () {
      final text = '${'أ' * 30}، ${'ب' * 30}، ${'ج' * 30}';

      expect(SpokenArabic.chunks(text, maxLength: 70).first, (
        start: 0,
        end: 63,
      ));
    });

    test('cuts between words when there is no punctuation', () {
      final text = List.filled(20, 'كلمة').join(' ');
      final chunks = SpokenArabic.chunks(text, maxLength: 30);

      for (final chunk in chunks) {
        final piece = text.substring(chunk.start, chunk.end).trim();
        expect(piece.split(' ').every((word) => word == 'كلمة'), isTrue);
      }
    });

    test('cuts a run without spaces at the limit', () {
      expect(SpokenArabic.chunks('أ' * 100, maxLength: 40), [
        (start: 0, end: 40),
        (start: 40, end: 80),
        (start: 80, end: 100),
      ]);
    });

    test('never makes a chunk longer than the limit', () {
      final text = List.filled(80, 'قال رسول الله، ').join();
      final chunks = SpokenArabic.chunks(text, maxLength: 100);

      expect(chunks.every((c) => c.end - c.start <= 100), isTrue);
      expect(chunks.last.end, text.length);
    });
  });
}
