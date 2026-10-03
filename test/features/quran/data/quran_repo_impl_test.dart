import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/quran/data/datasources/quran_text_local_datasource.dart';
import 'package:mishkat_almasabih/features/quran/data/repos/quran_repo_impl.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_metrics.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/tajweed_info.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_juz_index_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_page_info_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/search_quran_use_case.dart';
import 'package:mushaf_text/mushaf_text.dart';

import '../quran_fakes.dart';

/// Runs against the mushaf text bundled with `mushaf_text`, so these check
/// the real data rather than a fixture.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repo = QuranRepoImpl(QuranTextLocalDataSource());

  test('the domain metrics agree with the bundled mushaf', () async {
    final ayahs = dataOf(await repo.getAllAyahs());
    final surahs = dataOf(await repo.getSurahs());

    expect(QuranMetrics.pageCount, Quran.pageCount);
    expect(ayahs, hasLength(QuranMetrics.ayahCount));
    expect(surahs, hasLength(QuranMetrics.surahCount));
  });

  test('page 1 holds the seven ayahs of Al-Fātiḥah', () async {
    final ayahs = dataOf(await repo.getPageAyahs(1));

    expect(ayahs, hasLength(7));
    expect(ayahs.every((a) => a.surahNumber == 1), isTrue);
  });

  test('finds Āyat al-Kursī by its id', () async {
    final ayah = dataOf(await repo.getAyah(262));

    expect(ayah.surahNumber, 2);
    expect(ayah.number, 255);
  });

  test('the mushaf marks fifteen ayahs of prostration', () async {
    final ayahs = dataOf(await repo.getAllAyahs());

    expect(ayahs.where((a) => a.isSajdah), hasLength(15));
  });

  test('tajweed segments name real rules', () async {
    final segments = dataOf(
      await repo.getAyahTajweed(1, includeNaturalMadd: false),
    );
    final known = TajweedRule.values.map((r) => r.name).toSet();

    expect(segments, isNotEmpty);
    expect(segments.every((s) => known.contains(s.ruleKey)), isTrue);
  });

  test('page rule counts come most frequent first', () async {
    final counts = dataOf(
      await repo.getPageTajweedCounts(2, includeNaturalMadd: false),
    );

    expect(counts, isNotEmpty);
    for (var i = 1; i < counts.length; i++) {
      expect(counts[i - 1].count, greaterThanOrEqualTo(counts[i].count));
    }
  });

  test('there are thirty ajzāʾ, the second opening at 2:142', () async {
    final juzList = dataOf(await GetJuzIndexUseCase(repo)());

    expect(juzList, hasLength(QuranMetrics.juzCount));
    expect(juzList[1].startSurahNumber, 2);
    expect(juzList[1].startAyahNumber, 142);
    expect(juzList.last.startSurahNumber, 78);
  });

  test('the last page holds the final three surahs', () async {
    final info = dataOf(await GetPageInfoUseCase(repo)(604));

    expect(info.surahs.map((s) => s.number), [112, 113, 114]);
    expect(info.juz, 30);
  });

  test('the domain natural-madd key names the package rule', () {
    expect(TajweedRuleKeys.naturalMadd, TajweedRule.maddNatural.name);
  });

  test('a typed «يا أيها الذين آمنوا» finds the Uthmanic verses', () async {
    final results = dataOf(
      await SearchQuranUseCase(repo)('يا أيها الذين آمنوا'),
    );

    expect(results.totalMatches, greaterThan(80));
  });

  test('a typed «أقيموا الصلاة» finds «أَقِيمُواْ ٱلصَّلَوٰةَ»', () async {
    final results = dataOf(await SearchQuranUseCase(repo)('أقيموا الصلاة'));

    expect(results.hits, isNotEmpty);
  });

  test('searching without harakat finds the basmalah of Al-Fātiḥah', () async {
    final results = dataOf(await SearchQuranUseCase(repo)('بسم الله الرحمن'));

    expect(results.hits.first.ayah.id, 1);
  });
}
