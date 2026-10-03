import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/quran/domain/services/quran_text_normalizer.dart';

/// Whether a reader typing [typed] would find [uthmani].
bool _matches(String uthmani, String typed) => QuranTextNormalizer.normalize(
  uthmani,
).contains(QuranTextNormalizer.normalize(typed));

void main() {
  group('typed spelling matches the Uthmanic text', () {
    test('without harakat or the superscript alef', () {
      expect(_matches('ٱلرَّحۡمَٰنِ', 'الرحمن'), isTrue);
    });

    test('with the vocative written apart and the hamza on an alef', () {
      expect(
        _matches('يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوٓاْ', 'يا أيها الذين آمنوا'),
        isTrue,
      );
    });

    test('where Uthmanic script writes a waw for the alef', () {
      expect(_matches('وَأَقِيمُواْ ٱلصَّلَوٰةَ', 'الصلاة'), isTrue);
    });

    test('where the alef is only a superscript', () {
      expect(_matches('ذَٰلِكَ ٱلۡكِتَٰبُ', 'الكتاب'), isTrue);
    });

    test('where a small high yeh stands for an omitted yeh', () {
      expect(_matches('إِبۡرَٰهِـۧمَ', 'ابراهيم'), isTrue);
    });

    test('with teh marbuta typed as heh', () {
      expect(_matches('سُورَةُ ٱلۡبَقَرَةِ', 'البقره'), isTrue);
    });

    test('ignoring waqf signs inside the verse', () {
      expect(_matches('رَبِّهِمۡۖ وَأُوْلَٰٓئِكَ', 'ربهم واولئك'), isTrue);
    });

    test('ignoring extra spaces in the query', () {
      expect(_matches('ٱلۡحَمۡدُ لِلَّهِ', '  الحمد    لله '), isTrue);
    });
  });

  test('different words do not match', () {
    expect(_matches('ٱلرَّحۡمَٰنِ', 'الرحيم'), isFalse);
  });

  test('«لا إله» is not taken for «الله»', () {
    expect(_matches('لَآ إِلَٰهَ إِلَّا هُوَ', 'الله'), isFalse);
  });

  group('foldSpelling', () {
    test('drops marks and merges letter variants', () {
      expect(QuranTextNormalizer.foldSpelling('البَقَرَة'), 'البقره');
    });

    test('keeps the alef, so «الناس» and «النساء» stay apart', () {
      expect(
        QuranTextNormalizer.foldSpelling('النساء'),
        isNot(contains('الناس')),
      );
    });
  });

  test('leaves Latin text as it is', () {
    expect(QuranTextNormalizer.normalize('baqarah'), 'baqarah');
  });

  group('sourceRange', () {
    test('covers the whole word, wasla alef and final kasra included', () {
      const source = 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ';
      final normalized = QuranTextNormalizer.normalizeWithMap(source);
      final needle = QuranTextNormalizer.normalize('الرحمن');
      final at = normalized.value.indexOf(needle);

      final range = normalized.sourceRange(at, at + needle.length);

      expect(source.substring(range.start, range.end), 'ٱلرَّحۡمَٰنِ');
    });

    test('starts a mid-word match at its letter, not the one before', () {
      const source = 'ٱلرَّحۡمَٰنِ';
      final normalized = QuranTextNormalizer.normalizeWithMap(source);
      final needle = QuranTextNormalizer.normalize('حمن');
      final at = normalized.value.indexOf(needle);

      final range = normalized.sourceRange(at, at + needle.length);

      expect(source.substring(range.start, range.end), startsWith('ح'));
    });
  });
}
