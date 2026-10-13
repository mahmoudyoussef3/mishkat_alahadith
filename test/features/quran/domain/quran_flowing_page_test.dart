import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_ayah.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_flowing_page.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/tajweed_info.dart';

import '../quran_fakes.dart';

QuranFlowingAyah _flowing(
  QuranAyah ayah, [
  List<TajweedSegment> rules = const [],
]) => QuranFlowingAyah(ayah: ayah, tajweed: rules);

void main() {
  group('QuranFlowingAyah.words', () {
    test('splits an ayah into the runs between its spaces', () {
      final words = _flowing(hamd).words;

      // «ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَٰلَمِينَ»
      expect(words.map((w) => w.start), [0, 10, 18, 24]);
      expect(hamd.text.substring(words[1].start, words[1].end), 'لِلَّهِ');
    });

    test('skips repeated and trailing spaces', () {
      const spaced = QuranAyah(
        id: 1,
        surahNumber: 1,
        number: 1,
        juz: 1,
        page: 1,
        text: 'ab  c ',
      );

      expect(_flowing(spaced).words, [(start: 0, end: 2), (start: 4, end: 5)]);
    });
  });

  group('QuranFlowingPage.focusStop', () {
    const ikhfa = 'ikhfa';
    final page = QuranFlowingPage(
      page: 1,
      sections: [
        QuranFlowingSection(
          surah: fatihah,
          opensHere: true,
          ayahs: [
            // Twice in the first word, so it is still one stop.
            _flowing(basmalah, const [
              TajweedSegment(start: 0, end: 1, ruleKey: ikhfa),
              TajweedSegment(start: 2, end: 3, ruleKey: ikhfa),
            ]),
            _flowing(hamd, const [
              TajweedSegment(start: 19, end: 20, ruleKey: ikhfa),
              TajweedSegment(start: 10, end: 11, ruleKey: 'ghunna'),
            ]),
          ],
        ),
      ],
    );

    test('counts each word carrying the rule once, in reading order', () {
      expect(page.focusStop(ikhfa, 0), (ayahId: 1, charStart: 0));
      expect(page.focusStop(ikhfa, 1), (ayahId: 2, charStart: 18));
    });

    test('wraps past the last word back to the first', () {
      expect(page.focusStop(ikhfa, 2), (ayahId: 1, charStart: 0));
    });

    test('is null for a rule that is not on the page', () {
      expect(page.focusStop('iqlab', 0), isNull);
    });
  });
}
