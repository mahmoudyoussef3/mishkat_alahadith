import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/tajweed_info.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_ayah_details_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_juz_index_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_page_info_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_page_tajweed_counts_use_case.dart';

import '../quran_fakes.dart';

void main() {
  group('GetJuzIndexUseCase', () {
    test('lists each juz once, from its first ayah', () async {
      final juzList = dataOf(await GetJuzIndexUseCase(FakeQuranRepo())());

      expect(juzList.map((j) => j.number), [1, 2, 6]);
    });

    test('records the page, surah and ayah each juz opens on', () async {
      final juzList = dataOf(await GetJuzIndexUseCase(FakeQuranRepo())());
      final second = juzList[1];

      expect(second.startPage, 22);
      expect(second.startSurahName, 'البقرة');
      expect(second.startAyahNumber, 142);
    });

    test('fails when the ayahs cannot be loaded', () async {
      final result = await GetJuzIndexUseCase(FakeQuranRepo(failAyahs: true))();

      expect(result, isA<ApiFailure>());
    });
  });

  group('GetPageInfoUseCase', () {
    test('describes a page by its juz and ayah range', () async {
      final info = dataOf(await GetPageInfoUseCase(FakeQuranRepo())(1));

      expect(info.juz, 1);
      expect(info.firstAyahId, 1);
      expect(info.lastAyahId, 2);
    });

    test('lists every surah on a shared page, in reading order', () async {
      final info = dataOf(await GetPageInfoUseCase(FakeQuranRepo())(106));

      expect(info.surahs, [nisa, maidah]);
      expect(info.openingSurah, nisa);
    });

    test('rejects a page outside the mushaf', () async {
      final result = await GetPageInfoUseCase(FakeQuranRepo())(605);

      expect(result, isA<ApiFailure>());
    });

    test('fails for a page with no ayahs', () async {
      final result = await GetPageInfoUseCase(FakeQuranRepo())(300);

      expect(result, isA<ApiFailure>());
    });
  });

  group('GetAyahDetailsUseCase', () {
    test('joins the ayah with its surah and tajweed', () async {
      final repo = FakeQuranRepo(
        tajweed: {
          1: const [TajweedSegment(start: 0, end: 2, ruleKey: 'ghunna')],
        },
      );

      final details = dataOf(
        await GetAyahDetailsUseCase(repo)(1, includeNaturalMadd: false),
      );

      expect(details.ayah, basmalah);
      expect(details.surah, fatihah);
      expect(details.ruleKeys, ['ghunna']);
    });

    test('fails for an unknown ayah', () async {
      final result = await GetAyahDetailsUseCase(FakeQuranRepo())(
        9999,
        includeNaturalMadd: false,
      );

      expect(result, isA<ApiFailure>());
    });
  });

  group('GetPageTajweedCountsUseCase', () {
    test('passes the natural madd choice through to the repository', () async {
      final repo = FakeQuranRepo();

      await GetPageTajweedCountsUseCase(repo)(3, includeNaturalMadd: true);

      expect(repo.countRequests.single, (page: 3, includeNaturalMadd: true));
    });

    test('rejects a page outside the mushaf without asking', () async {
      final repo = FakeQuranRepo();

      final result = await GetPageTajweedCountsUseCase(repo)(
        0,
        includeNaturalMadd: false,
      );

      expect(result, isA<ApiFailure>());
      expect(repo.countRequests, isEmpty);
    });
  });
}
