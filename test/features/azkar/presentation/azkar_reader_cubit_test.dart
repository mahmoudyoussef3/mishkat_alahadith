import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_day_progress.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_settings.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_reader/azkar_reader_cubit.dart';

import '../azkar_fakes.dart';

void main() {
  late FakeAzkarRepo repo;
  late AzkarReaderCubit cubit;

  setUp(() {
    repo = FakeAzkarRepo();
    cubit = readerCubitFor(repo);
  });

  tearDown(() => cubit.close());

  AzkarReaderLoaded loaded() => cubit.state as AzkarReaderLoaded;

  group('load', () {
    test('opens the chapter asked for', () async {
      await cubit.load(27);

      expect(loaded().category.id, 27);
      expect(loaded().counts, isEmpty);
      expect(loaded().focus, isNull);
    });

    test('fails for a chapter that is not in the book', () async {
      await cubit.load(999);

      expect(
        (cubit.state as AzkarReaderFailure).message,
        AzkarReaderCubit.notFoundMessage,
      );
    });

    test('fails when the book cannot be read', () async {
      repo.failCatalog = true;

      await cubit.load(27);

      expect(cubit.state, isA<AzkarReaderFailure>());
    });

    test('opens at the zikr asked for', () async {
      await cubit.load(27, zikrId: 3);

      expect(loaded().focus?.zikrId, 3);
    });

    test('resumes at the first unfinished zikr from today', () async {
      repo.progress = AzkarDayProgress.emptyOn(
        morningClock(),
      ).withCount(27, 1, 1);

      await cubit.load(27);

      expect(loaded().countOf(1), 1);
      expect(loaded().focus?.zikrId, 2);
    });

    test('loads the saved translation and favourite', () async {
      repo
        ..settings = AzkarSettings.defaults.copyWith(
          translation: AzkarTranslation.english,
        )
        ..favoriteIds = [27];

      await cubit.load(27);

      expect(loaded().category.translatedTitle, isNotNull);
      expect(loaded().isFavorite, isTrue);
    });
  });

  group('count', () {
    setUp(() => cubit.load(27));

    test('counts one repetition and saves it', () async {
      final outcome = cubit.count(2);
      await pumpEventQueue();

      expect(outcome, ZikrCountOutcome.counted);
      expect(loaded().countOf(2), 1);
      expect(repo.progress!.countOf(27, 2), 1);
    });

    test('says when a zikr is finished', () {
      cubit
        ..count(2)
        ..count(2);

      expect(cubit.count(2), ZikrCountOutcome.zikrCompleted);
    });

    test('ignores a zikr that is already done', () {
      cubit.count(1);

      expect(cubit.count(1), ZikrCountOutcome.ignored);
      expect(loaded().countOf(1), 1);
    });

    test('ignores a zikr that is not in the chapter', () {
      expect(cubit.count(42), ZikrCountOutcome.ignored);
    });

    test('moves on to the next unfinished zikr when one is done', () {
      cubit.count(1);

      expect(loaded().focus?.zikrId, 2);
    });

    test('stays put when moving on is turned off', () async {
      await cubit.updateSettings(
        AzkarSettings.defaults.copyWith(autoAdvance: false),
      );

      cubit.count(1);

      expect(loaded().focus, isNull);
    });

    test('says when the whole chapter is done', () {
      cubit.count(1);
      for (var i = 0; i < 3; i++) {
        cubit.count(2);
      }
      for (var i = 0; i < 99; i++) {
        cubit.count(3);
      }

      expect(cubit.count(3), ZikrCountOutcome.categoryCompleted);
      expect(loaded().progress.isComplete, isTrue);
    });

    test('reports a count that could not be saved', () async {
      repo.failProgressWrites = true;

      cubit.count(2);
      await pumpEventQueue();

      expect(loaded().failedSaves, 1);
      expect(loaded().countOf(2), 1);
    });
  });

  group('reset', () {
    setUp(() async {
      await cubit.load(27);
      cubit
        ..count(1)
        ..count(2);
      await pumpEventQueue();
    });

    test('resetZikr starts one zikr over', () async {
      await cubit.resetZikr(2);

      expect(loaded().countOf(2), 0);
      expect(loaded().countOf(1), 1);
      expect(repo.progress!.countOf(27, 2), 0);
    });

    test('resetAll starts the chapter over from its first zikr', () async {
      await cubit.resetAll();

      expect(loaded().counts, isEmpty);
      expect(loaded().focus?.zikrId, 1);
      expect(repo.progress!.countsFor(27), isEmpty);
    });
  });

  group('settings', () {
    setUp(() => cubit.load(27));

    test('are applied and saved', () async {
      final chosen = AzkarSettings.defaults.copyWith(
        fontScale: AzkarFontScale.large,
      );

      await cubit.updateSettings(chosen);

      expect(loaded().settings, chosen);
      expect(repo.settings, chosen);
    });

    test('a save that fails is reported', () async {
      repo.failSettingsSave = true;

      await cubit.updateSettings(
        AzkarSettings.defaults.copyWith(fontScale: AzkarFontScale.large),
      );

      expect(loaded().failedSaves, 1);
      expect(loaded().settings.fontScale, AzkarFontScale.large);
    });

    test('a slow translation never replaces a later choice', () async {
      final english = repo.catalogHolds[AzkarTranslation.english] = Completer();
      final slow = cubit.updateSettings(
        AzkarSettings.defaults.copyWith(translation: AzkarTranslation.english),
      );
      await pumpEventQueue();
      await cubit.updateSettings(AzkarSettings.defaults);

      english.complete();
      await slow;

      expect(loaded().settings.translation, AzkarTranslation.none);
      expect(loaded().category.translatedTitle, isNull);
    });

    test('a new translation is loaded in under the same counts', () async {
      cubit.count(2);

      await cubit.updateSettings(
        AzkarSettings.defaults.copyWith(translation: AzkarTranslation.english),
      );

      expect(loaded().category.azkar.first.translation, isNotNull);
      expect(loaded().countOf(2), 1);
    });
  });

  group('a new day', () {
    late DateTime now;

    setUp(() async {
      await cubit.close();
      now = DateTime(2026, 11, 5, 23, 50);
      cubit = readerCubitFor(repo, now: () => now);
      await cubit.load(27);
      cubit
        ..count(3)
        ..count(3);
      await pumpEventQueue();
    });

    test('drops yesterday\'s counts instead of carrying them over', () async {
      now = DateTime(2026, 11, 6, 0, 5);

      cubit.count(3);
      await pumpEventQueue();

      expect(loaded().day, DateTime(2026, 11, 6));
      expect(loaded().counts, isEmpty);
      expect(repo.progress!.day, DateTime(2026, 11, 6));
      expect(repo.progress!.countsFor(27), isEmpty);
    });

    test('is picked up when the app comes back', () async {
      now = DateTime(2026, 11, 6, 7);

      await cubit.refreshProgress();

      expect(loaded().counts, isEmpty);
      expect(loaded().focus?.zikrId, 1);
    });

    test('changes nothing when it is still the same day', () async {
      await cubit.refreshProgress();

      expect(loaded().countOf(3), 2);
    });
  });

  group('toggleFavorite', () {
    setUp(() => cubit.load(27));

    test('stars the chapter', () async {
      expect(await cubit.toggleFavorite(), isTrue);
      expect(loaded().isFavorite, isTrue);
      expect(repo.favoriteIds, [27]);
    });

    test('returns null when it cannot be saved', () async {
      repo.failFavorites = true;

      expect(await cubit.toggleFavorite(), isNull);
      expect(loaded().isFavorite, isFalse);
    });
  });
}
