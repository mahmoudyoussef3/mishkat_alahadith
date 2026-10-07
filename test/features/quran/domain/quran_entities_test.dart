import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/ayah_details.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/mushaf_reader_settings.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_ayah.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_juz.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_metrics.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_surah.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/tajweed_info.dart';

import '../quran_fakes.dart';

void main() {
  group('QuranSurah.openingAt', () {
    test('names the surah a page belongs to', () {
      expect(QuranSurah.openingAt(sampleSurahs, 30), baqarah);
    });

    test('gives a shared page to the surah still running at its top', () {
      expect(QuranSurah.openingAt(sampleSurahs, 106), nisa);
    });

    test('is null for a page no surah covers', () {
      expect(QuranSurah.openingAt(sampleSurahs, 300), isNull);
    });
  });

  group('QuranSurah.numbered', () {
    test('finds the surah with that number', () {
      expect(QuranSurah.numbered(sampleSurahs, 5), maidah);
    });

    test('is null for a number the list does not have', () {
      expect(QuranSurah.numbered(sampleSurahs, 3), isNull);
    });

    test('is null when no number is given', () {
      expect(QuranSurah.numbered(sampleSurahs, null), isNull);
    });
  });

  group('QuranSurah.readingAt', () {
    test('keeps the surah being read on a page another surah opens', () {
      expect(QuranSurah.readingAt(sampleSurahs, 106, current: maidah), maidah);
    });

    test('moves on to the surah the page opens with past its end', () {
      expect(QuranSurah.readingAt(sampleSurahs, 107, current: nisa), maidah);
    });

    test('is the surah the page opens with when none is being read', () {
      expect(QuranSurah.readingAt(sampleSurahs, 106), nisa);
    });
  });

  test('the mushaf is coloured with tajweed by default', () {
    expect(MushafReaderSettings.defaults.tajweedEnabled, isTrue);
  });

  group('QuranJuz.containingPage', () {
    const juzList = [
      QuranJuz(
        number: 1,
        startPage: 1,
        startSurahNumber: 1,
        startSurahName: 'الفاتحة',
        startAyahNumber: 1,
      ),
      QuranJuz(
        number: 2,
        startPage: 22,
        startSurahNumber: 2,
        startSurahName: 'البقرة',
        startAyahNumber: 142,
      ),
    ];

    test('finds the juz a page falls inside', () {
      expect(QuranJuz.containingPage(juzList, 21)?.number, 1);
    });

    test('finds the juz that starts on the page', () {
      expect(QuranJuz.containingPage(juzList, 22)?.number, 2);
    });
  });

  group('QuranBookmark.sameTargetAs', () {
    test('matches two page bookmarks on the same page', () {
      expect(
        pageBookmark(5).sameTargetAs(pageBookmark(5, at: DateTime(2027))),
        isTrue,
      );
    });

    test('does not confuse a page bookmark with an ayah on that page', () {
      expect(pageBookmark(1).sameTargetAs(ayahBookmark(1, page: 1)), isFalse);
    });

    test('matches two ayah bookmarks on the same ayah', () {
      expect(ayahBookmark(7).sameTargetAs(ayahBookmark(7)), isTrue);
    });
  });

  test('an ayah carrying the sajdah sign is a sajdah ayah', () {
    const ayah = QuranAyah(
      id: 1160,
      surahNumber: 7,
      number: 206,
      juz: 9,
      page: 176,
      text: 'وَلَهُۥ يَسۡجُدُونَۤ۩',
    );

    expect(ayah.isSajdah, isTrue);
    expect(basmalah.isSajdah, isFalse);
  });

  test('AyahDetails lists each rule once, in the order it first occurs', () {
    const details = AyahDetails(
      ayah: basmalah,
      surah: fatihah,
      tajweed: [
        TajweedSegment(start: 0, end: 1, ruleKey: 'ghunna'),
        TajweedSegment(start: 2, end: 3, ruleKey: 'ikhfa'),
        TajweedSegment(start: 4, end: 5, ruleKey: 'ghunna'),
      ],
    );

    expect(details.ruleKeys, ['ghunna', 'ikhfa']);
  });

  group('QuranMetrics', () {
    test('accepts the first and last pages', () {
      expect(QuranMetrics.isValidPage(1), isTrue);
      expect(QuranMetrics.isValidPage(604), isTrue);
    });

    test('rejects pages outside the mushaf', () {
      expect(QuranMetrics.isValidPage(0), isFalse);
      expect(QuranMetrics.isValidPage(605), isFalse);
    });

    test('clamps an out-of-range page to the nearest real one', () {
      expect(QuranMetrics.clampPage(900), 604);
      expect(QuranMetrics.clampPage(-3), 1);
    });
  });
}
