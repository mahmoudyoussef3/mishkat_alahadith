import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_collection.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_day_progress.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_settings.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_suggestion.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_home/azkar_home_cubit.dart';

import '../azkar_fakes.dart';

void main() {
  late FakeAzkarRepo repo;
  late AzkarHomeCubit cubit;

  setUp(() {
    repo = FakeAzkarRepo();
    cubit = homeCubitFor(repo);
  });

  tearDown(() => cubit.close());

  AzkarHomeLoaded loaded() => cubit.state as AzkarHomeLoaded;

  test('loads the book, the suggestion for the hour and today', () async {
    await cubit.load();

    expect(loaded().categories, hasLength(sampleCatalog.length));
    expect(loaded().suggestion.timeOfDay, AzkarTimeOfDay.morning);
    expect(loaded().progress?.counts, isEmpty);
    expect(loaded().isSearching, isFalse);
  });

  test('fails when the book cannot be read', () async {
    repo.failCatalog = true;

    await cubit.load();

    expect(cubit.state, isA<AzkarHomeFailure>());
  });

  test('loads in the saved translation, for search', () async {
    repo.settings = AzkarSettings.defaults.copyWith(
      translation: AzkarTranslation.english,
    );

    await cubit.load();

    expect(repo.catalogRequests, [AzkarTranslation.english]);
  });

  test('numbers chapters by their place in the book', () async {
    await cubit.load();

    expect(loaded().numberOf(sleep), 2);
  });

  test('a collection narrows the chapters', () async {
    await cubit.load();

    cubit.selectCollection(AzkarCollection.travel);

    expect(loaded().visibleCategories.single.id, 96);
  });

  test('searches a query typed while the book was loading', () async {
    cubit.search('النوم');

    await cubit.load();

    expect(loaded().query, 'النوم');
    expect(loaded().searchResults?.categories.single.id, 28);
  });

  group('search', () {
    setUp(() => cubit.load());

    test('finds azkar as the reader types', () {
      cubit.search('سبحان الله');

      expect(loaded().searchResults?.hits.single.zikr.id, 2);
    });

    test('a query too short to search shows the home again', () {
      cubit
        ..search('سبحان')
        ..search('س');

      expect(loaded().isSearching, isFalse);
      expect(loaded().query, 'س');
    });
  });

  group('favourites', () {
    setUp(() => cubit.load());

    test('starring a chapter shows it among the favourites', () async {
      final saved = await cubit.toggleFavorite(28);

      expect(saved, isTrue);
      expect(loaded().favorites.single.id, 28);
    });

    test('a saved change shows even if re-reading would fail', () async {
      repo.failFavoriteReads = true;

      await cubit.toggleFavorite(28);

      expect(loaded().favoriteIds, [28]);
    });

    test('unstarring removes only that chapter', () async {
      await cubit.toggleFavorite(28);
      await cubit.toggleFavorite(27);

      await cubit.toggleFavorite(28);

      expect(loaded().favoriteIds, [27]);
    });

    test('a change that cannot be saved is reported', () async {
      repo.failFavorites = true;

      expect(await cubit.toggleFavorite(28), isFalse);
    });
  });

  test('refresh picks up what was counted in a chapter', () async {
    await cubit.load();
    repo.progress = AzkarDayProgress.emptyOn(
      morningClock(),
    ).withCount(27, 1, 1);

    await cubit.refresh();

    expect(loaded().progressOf(morningEvening).completedAzkar, 1);
  });

  test('refresh re-runs the search in a newly chosen translation', () async {
    await cubit.load();
    cubit.search('Meaning 28');
    expect(loaded().searchResults!.isEmpty, isTrue);
    repo.settings = AzkarSettings.defaults.copyWith(
      translation: AzkarTranslation.english,
    );

    await cubit.refresh();

    expect(loaded().searchResults!.hits.single.category.id, 28);
  });
}
