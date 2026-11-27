import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_ayah.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/tajweed_info.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_flowing_page_use_case.dart';

import '../quran_fakes.dart';

void main() {
  group('GetFlowingPageUseCase', () {
    test('groups a shared page by surah, in reading order', () async {
      final page = dataOf(
        await GetFlowingPageUseCase(FakeQuranRepo())(
          106,
          includeNaturalMadd: false,
        ),
      );

      expect(page.sections.map((s) => s.surah), [nisa, maidah]);
      expect(page.sections.first.ayahs.single.ayah, nisaLast);
      expect(page.sections.last.ayahs.single.ayah, maidahFirst);
    });

    test('titles only the surah whose first ayah is on the page', () async {
      final page = dataOf(
        await GetFlowingPageUseCase(FakeQuranRepo())(
          106,
          includeNaturalMadd: false,
        ),
      );

      expect(page.sections.map((s) => s.opensHere), [false, true]);
      expect(page.sections.map((s) => s.showsBasmala), [false, true]);
    });

    test('gives Al-Fatihah no basmala apart from its first ayah', () async {
      final page = dataOf(
        await GetFlowingPageUseCase(FakeQuranRepo())(
          1,
          includeNaturalMadd: false,
        ),
      );

      final section = page.sections.single;
      expect(section.opensHere, isTrue);
      expect(section.showsBasmala, isFalse);
      expect(section.ayahs.map((a) => a.ayah), [basmalah, hamd]);
    });

    test('attaches each ayah its own tajweed', () async {
      const ghunna = TajweedSegment(start: 0, end: 2, ruleKey: 'ghunna');
      final repo = FakeQuranRepo(
        tajweed: {
          2: const [ghunna],
        },
      );

      final page = dataOf(
        await GetFlowingPageUseCase(repo)(1, includeNaturalMadd: false),
      );

      final ayahs = page.sections.single.ayahs;
      expect(ayahs.first.tajweed, isEmpty);
      expect(ayahs.last.tajweed, [ghunna]);
    });

    test('passes the natural madd choice through to the repository', () async {
      final repo = FakeQuranRepo();

      await GetFlowingPageUseCase(repo)(1, includeNaturalMadd: true);

      expect(
        repo.tajweedRequests.map((r) => r.includeNaturalMadd),
        everyElement(isTrue),
      );
      expect(repo.tajweedRequests.map((r) => r.ayahId), [1, 2]);
    });

    test('rejects a page outside the mushaf without asking', () async {
      final repo = FakeQuranRepo();

      final result = await GetFlowingPageUseCase(repo)(
        605,
        includeNaturalMadd: false,
      );

      expect(result, isA<ApiFailure>());
      expect(repo.tajweedRequests, isEmpty);
    });

    test('fails when the ayahs cannot be loaded', () async {
      final result = await GetFlowingPageUseCase(
        FakeQuranRepo(failAyahs: true),
      )(1, includeNaturalMadd: false);

      expect(result, isA<ApiFailure>());
    });

    test('fails when the tajweed cannot be loaded', () async {
      final result = await GetFlowingPageUseCase(
        FakeQuranRepo(failTajweed: true),
      )(1, includeNaturalMadd: false);

      expect(result, isA<ApiFailure>());
    });

    test('fails for a page with no ayahs', () async {
      final result = await GetFlowingPageUseCase(FakeQuranRepo())(
        300,
        includeNaturalMadd: false,
      );

      expect(result, isA<ApiFailure>());
    });

    test('fails for an ayah whose surah is not in the table', () async {
      const stray = QuranAyah(
        id: 9000,
        surahNumber: 50,
        number: 1,
        juz: 26,
        page: 518,
        text: 'قٓۚ',
      );
      final result = await GetFlowingPageUseCase(
        FakeQuranRepo(ayahs: const [stray]),
      )(518, includeNaturalMadd: false);

      expect(result, isA<ApiFailure>());
    });
  });
}
