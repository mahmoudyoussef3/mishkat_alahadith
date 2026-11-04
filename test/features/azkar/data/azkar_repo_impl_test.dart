import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/azkar/data/datasources/azkar_catalog_local_datasource.dart';
import 'package:mishkat_almasabih/features/azkar/data/datasources/azkar_preferences_local_datasource.dart';
import 'package:mishkat_almasabih/features/azkar/data/repos/azkar_repo_impl.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_day_progress.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../azkar_fakes.dart';

class _Bundle extends AssetBundle {
  final Map<String, String> files;

  _Bundle(this.files);

  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      files[key] ?? (throw StateError('No asset $key'));

  @override
  Future<ByteData> load(String key) => throw UnimplementedError();

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) => throw UnimplementedError();
}

const _arabic = '''
[{"id":27,"category":"أذكار الصباح والمساء","audio":"/audio/a.mp3","array":[
  {"id":1,"text":"سبحان الله","count":3,"audio":"/audio/1.mp3"},
  {"id":2,"text":"الحمد لله","count":1,"audio":""}]}]''';

const _english = '''
[{"id":27,"category":"Morning and evening","audio":"/audio/a.mp3","array":[
  {"id":1,"text":"Glory be to Allah","transliteration":"Subhan Allah","count":3},
  {"id":2,"text":"الحمد لله","count":1}]}]''';

AzkarRepoImpl _repo({Map<String, String>? files}) => AzkarRepoImpl(
  AzkarCatalogLocalDataSource(
    bundle: _Bundle(
      files ??
          {'assets/azkar/ar.json': _arabic, 'assets/azkar/en.json': _english},
    ),
  ),
  AzkarPreferencesLocalDataSource(),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('categories', () {
    test('carry no translation when none is chosen', () async {
      final category =
          dataOf(await _repo().getCategories(AzkarTranslation.none)).single;

      expect(category.translatedTitle, isNull);
      expect(category.azkar.first.translation, isNull);
      expect(category.azkar.first.audioFile, '1.mp3');
      expect(category.azkar.last.audioFile, isNull);
    });

    test('carry the chosen translation under the Arabic', () async {
      final category =
          dataOf(await _repo().getCategories(AzkarTranslation.english)).single;

      expect(category.title, 'أذكار الصباح والمساء');
      expect(category.translatedTitle, 'Morning and evening');
      expect(category.azkar.first.translation, 'Glory be to Allah');
      expect(category.azkar.first.transliteration, 'Subhan Allah');
    });

    test('drop a translation that only repeats the Arabic', () async {
      final category =
          dataOf(await _repo().getCategories(AzkarTranslation.english)).single;

      expect(category.azkar.last.translation, isNull);
    });

    test('fail when the book cannot be read', () async {
      final result = await _repo(
        files: {},
      ).getCategories(AzkarTranslation.none);

      expect(result, isA<ApiFailure>());
    });
  });

  group('favourites', () {
    test('round-trip in order', () async {
      final repo = _repo();
      await repo.updateFavoriteIds((_) => [28, 27]);

      expect(dataOf(await repo.getFavoriteIds()), [28, 27]);
    });

    test('apply concurrent updates one after another', () async {
      final repo = _repo();

      await Future.wait([
        repo.updateFavoriteIds((ids) => [...ids, 1]),
        repo.updateFavoriteIds((ids) => [...ids, 2]),
      ]);

      expect(dataOf(await repo.getFavoriteIds()), [1, 2]);
    });
  });

  group('progress', () {
    test('is null before anything is counted', () async {
      expect(dataOf(await _repo().getProgress()), isNull);
    });

    test('round-trips the day and its counts', () async {
      final repo = _repo();
      final day = AzkarDayProgress.emptyOn(DateTime(2026, 11, 5, 7));
      await repo.updateProgress((_) => day.withCount(27, 2, 3));

      final stored = dataOf(await repo.getProgress())!;

      expect(stored.day, DateTime(2026, 11, 5));
      expect(stored.countOf(27, 2), 3);
    });

    test('apply concurrent counts one after another', () async {
      final repo = _repo();
      final day = AzkarDayProgress.emptyOn(DateTime(2026, 11, 5));

      await Future.wait([
        for (var i = 1; i <= 5; i++)
          repo.updateProgress(
            (stored) => (stored ?? day).withCount(
              27,
              1,
              (stored ?? day).countOf(27, 1) + 1,
            ),
          ),
      ]);

      expect(dataOf(await repo.getProgress())!.countOf(27, 1), 5);
    });

    test('replaces stored progress that cannot be read', () async {
      SharedPreferences.setMockInitialValues({'azkar_progress': 'not json'});
      final repo = _repo();

      final result = await repo.updateProgress(
        (stored) => AzkarDayProgress.emptyOn(
          DateTime(2026, 11, 5),
        ).withCount(27, 1, stored == null ? 1 : 99),
      );

      expect(dataOf(result).countOf(27, 1), 1);
    });
  });

  group('settings', () {
    test('default before anything is saved', () async {
      expect(dataOf(await _repo().getSettings()), AzkarSettings.defaults);
    });

    test('round-trip', () async {
      final repo = _repo();
      const chosen = AzkarSettings(
        translation: AzkarTranslation.english,
        fontScale: AzkarFontScale.large,
        hapticFeedback: false,
        autoAdvance: false,
      );
      await repo.saveSettings(chosen);

      expect(dataOf(await repo.getSettings()), chosen);
    });

    test('fall back to the default for an unknown stored value', () async {
      SharedPreferences.setMockInitialValues({'azkar_translation': 'klingon'});

      final settings = dataOf(await _repo().getSettings());

      expect(settings.translation, AzkarTranslation.none);
    });
  });
}
