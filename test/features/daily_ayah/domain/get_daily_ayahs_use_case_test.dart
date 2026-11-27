import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/entities/ayah_reference.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/services/daily_ayah_rotation.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/usecases/get_daily_ayahs_use_case.dart';

import '../../quran/quran_fakes.dart';
import '../daily_ayah_fakes.dart';

void main() {
  final from = DateTime(2026, 10, 23, 14, 30);

  GetDailyAyahsUseCase useCaseWith({
    FakeDailyAyahRepo? repo,
    FakeQuranRepo? quranRepo,
  }) => GetDailyAyahsUseCase(
    repo ?? FakeDailyAyahRepo(),
    quranRepo ?? FakeQuranRepo(),
  );

  test('gives one ayah per day, from the calendar day of `from`', () async {
    final result = await useCaseWith()(from: from, days: 3);

    expect(dataOf(result).map((a) => a.day), [
      DateTime(2026, 10, 23),
      DateTime(2026, 10, 24),
      DateTime(2026, 10, 25),
    ]);
  });

  test("each day gets the catalog entry the rotation picks for it", () async {
    final result = await useCaseWith()(from: from, days: 5);

    for (final dailyAyah in dataOf(result)) {
      final expected =
          sampleCatalog[DailyAyahRotation.indexFor(
            dailyAyah.day,
            sampleCatalog.length,
          )];
      expect(dailyAyah.ayah.surahNumber, expected.surah);
      expect(dailyAyah.ayah.number, expected.ayah);
      expect(dailyAyah.surah.number, expected.surah);
    }
  });

  test('defaults to just the one day', () async {
    final result = await useCaseWith()(from: from);

    expect(dataOf(result), hasLength(1));
  });

  test('fails when the catalog cannot be read', () async {
    final result = await useCaseWith(
      repo: FakeDailyAyahRepo(failCatalog: true),
    )(from: from);

    expect(result, isA<ApiFailure<dynamic>>());
  });

  test('fails when the surahs cannot be read', () async {
    final result = await useCaseWith(
      quranRepo: FakeQuranRepo(failSurahs: true),
    )(from: from);

    expect(result, isA<ApiFailure<dynamic>>());
  });

  test('fails when the mushaf text cannot be read', () async {
    final result = await useCaseWith(
      quranRepo: FakeQuranRepo(failAyahs: true),
    )(from: from);

    expect(result, isA<ApiFailure<dynamic>>());
  });

  test('fails rather than skip a day whose ayah is not in the mushaf', () async {
    final result = await useCaseWith(
      repo: FakeDailyAyahRepo(catalog: const [AyahReference(2, 999)]),
    )(from: from);

    expect(result, isA<ApiFailure<dynamic>>());
  });

  test('fails on an empty catalog', () async {
    final result = await useCaseWith(
      repo: FakeDailyAyahRepo(catalog: const []),
    )(from: from);

    expect(result, isA<ApiFailure<dynamic>>());
  });
}
