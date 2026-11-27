import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_category.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_day_progress.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_suggestion.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/get_suggested_azkar_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/get_today_azkar_progress_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/reset_azkar_category_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/set_zikr_count_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/toggle_favorite_azkar_use_case.dart';

import '../azkar_fakes.dart';

void main() {
  group('GetSuggestedAzkarUseCase', () {
    AzkarSuggestion at(int hour) =>
        GetSuggestedAzkarUseCase(now: () => DateTime(2026, 11, 5, hour))();

    test('suggests the morning remembrances from 4 until noon', () {
      expect(at(4).timeOfDay, AzkarTimeOfDay.morning);
      expect(at(11).categoryId, AzkarCategoryIds.morningEvening);
    });

    test('suggests the remembrances after prayer around midday', () {
      expect(at(12).categoryId, AzkarCategoryIds.afterPrayer);
      expect(at(14).timeOfDay, AzkarTimeOfDay.midday);
    });

    test('suggests the evening remembrances from the afternoon', () {
      expect(at(15).timeOfDay, AzkarTimeOfDay.evening);
      expect(at(20).categoryId, AzkarCategoryIds.morningEvening);
    });

    test('suggests the remembrances before sleep at night', () {
      expect(at(21).categoryId, AzkarCategoryIds.sleep);
      expect(at(3).timeOfDay, AzkarTimeOfDay.night);
    });
  });

  group('GetTodayAzkarProgressUseCase', () {
    test('returns the stored counts from today', () async {
      final repo =
          FakeAzkarRepo()
            ..progress = AzkarDayProgress.emptyOn(
              morningClock(),
            ).withCount(27, 1, 1);

      final today = dataOf(
        await GetTodayAzkarProgressUseCase(repo, now: morningClock)(),
      );

      expect(today.countOf(27, 1), 1);
    });

    test('returns an empty day when the counts are from yesterday', () async {
      final repo =
          FakeAzkarRepo()
            ..progress = AzkarDayProgress.emptyOn(
              DateTime(2026, 11, 4, 22),
            ).withCount(27, 1, 1);

      final today = dataOf(
        await GetTodayAzkarProgressUseCase(repo, now: morningClock)(),
      );

      expect(today.day, DateTime(2026, 11, 5));
      expect(today.counts, isEmpty);
    });
  });

  group('SetZikrCountUseCase', () {
    test('drops yesterday\'s counts on the first count of a new day', () async {
      final repo =
          FakeAzkarRepo()
            ..progress = AzkarDayProgress.emptyOn(
              DateTime(2026, 11, 4, 22),
            ).withCount(28, 1, 1);

      await SetZikrCountUseCase(repo, now: morningClock)(
        categoryId: 27,
        zikrId: 2,
        count: 1,
      );

      expect(repo.progress!.counts, {
        27: {2: 1},
      });
    });
  });

  group('SetZikrCountUseCase on a day that has passed', () {
    test('records nothing and hands back a fresh today', () async {
      final repo =
          FakeAzkarRepo()
            ..progress = AzkarDayProgress.emptyOn(
              DateTime(2026, 11, 4, 23),
            ).withCount(27, 3, 99);

      final today = dataOf(
        await SetZikrCountUseCase(repo, now: morningClock)(
          categoryId: 27,
          zikrId: 3,
          count: 100,
          day: DateTime(2026, 11, 4),
        ),
      );

      expect(today.day, DateTime(2026, 11, 5));
      expect(today.counts, isEmpty);
      expect(repo.progress!.counts, isEmpty);
    });
  });

  group('ResetAzkarCategoryUseCase', () {
    test('clears only the chapter asked for', () async {
      final repo =
          FakeAzkarRepo()
            ..progress = AzkarDayProgress.emptyOn(
              morningClock(),
            ).withCount(27, 1, 1).withCount(28, 1, 1);

      await ResetAzkarCategoryUseCase(repo, now: morningClock)(27);

      expect(repo.progress!.counts.keys, [28]);
    });
  });

  group('ToggleFavoriteAzkarUseCase', () {
    test('adds a chapter to the front of the favourites', () async {
      final repo = FakeAzkarRepo()..favoriteIds = [28];

      final added = dataOf(await ToggleFavoriteAzkarUseCase(repo)(27));

      expect(added, isTrue);
      expect(repo.favoriteIds, [27, 28]);
    });

    test('removes a chapter that is already a favourite', () async {
      final repo = FakeAzkarRepo()..favoriteIds = [27, 28];

      final added = dataOf(await ToggleFavoriteAzkarUseCase(repo)(27));

      expect(added, isFalse);
      expect(repo.favoriteIds, [28]);
    });

    test('fails when the favourites cannot be saved', () async {
      final repo = FakeAzkarRepo()..failFavorites = true;

      expect(await ToggleFavoriteAzkarUseCase(repo)(27), isA<ApiFailure>());
    });
  });
}
