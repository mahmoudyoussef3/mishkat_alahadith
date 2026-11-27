import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/data/datasources/quran_reading_local_datasource.dart';
import 'package:mishkat_almasabih/features/quran/data/repos/quran_reading_repo_impl.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/mushaf_reader_settings.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_last_read.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../quran_fakes.dart';

void main() {
  late QuranReadingRepoImpl repo;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repo = QuranReadingRepoImpl(QuranReadingLocalDataSource());
  });

  group('last read', () {
    test('is null before anything is saved', () async {
      expect(dataOf(await repo.getLastRead()), isNull);
    });

    test('returns the page and time that were saved', () async {
      final savedAt = DateTime(2026, 10, 3, 21, 15);
      await repo.saveLastRead(QuranLastRead(page: 77, savedAt: savedAt));

      final lastRead = dataOf(await repo.getLastRead());

      expect(lastRead?.page, 77);
      expect(lastRead?.savedAt, savedAt);
    });

    test('ignores a stored page outside the mushaf', () async {
      SharedPreferences.setMockInitialValues({'quran_last_read_page': 999});

      expect(dataOf(await repo.getLastRead()), isNull);
    });
  });

  group('bookmarks', () {
    test('are empty before anything is saved', () async {
      expect(dataOf(await repo.getBookmarks()), isEmpty);
    });

    test('round-trip page and ayah bookmarks', () async {
      final saved = [pageBookmark(12), ayahBookmark(255, page: 42)];
      await repo.updateBookmarks((_) => saved);

      final loaded = dataOf(await repo.getBookmarks());

      expect(loaded, hasLength(2));
      expect(loaded.first.isPageBookmark, isTrue);
      expect(loaded.last.ayahId, 255);
      expect(loaded.last.createdAt, saved.last.createdAt);
    });

    test('skip a stored entry that is missing fields', () async {
      SharedPreferences.setMockInitialValues({
        'quran_bookmarks':
            '[{"page":3},{"page":4,"surahNumber":2,"surahName":"البقرة","createdAt":0}]',
      });

      final loaded = dataOf(await repo.getBookmarks());

      expect(loaded.single.page, 4);
    });

    test('apply concurrent updates one after another', () async {
      await Future.wait([
        repo.updateBookmarks((current) => [...current, pageBookmark(1)]),
        repo.updateBookmarks((current) => [...current, pageBookmark(2)]),
      ]);

      final loaded = dataOf(await repo.getBookmarks());

      expect(loaded.map((b) => b.page), [1, 2]);
    });

    test('fail when the stored value is not a list', () async {
      SharedPreferences.setMockInitialValues({'quran_bookmarks': '{"x":1}'});

      expect(await repo.getBookmarks(), isA<ApiFailure>());
    });
  });

  group('settings', () {
    test('default to plain text in the system theme', () async {
      expect(dataOf(await repo.getSettings()), MushafReaderSettings.defaults);
    });

    test('round-trip every field', () async {
      const settings = MushafReaderSettings(
        tajweedEnabled: true,
        naturalMaddEnabled: true,
        themeMode: MushafThemeMode.night,
        layoutMode: MushafLayoutMode.flowing,
        fontScale: QuranFontScale.huge,
      );
      await repo.saveSettings(settings);

      expect(dataOf(await repo.getSettings()), settings);
    });

    test('fall back to the system theme for an unknown stored value', () async {
      SharedPreferences.setMockInitialValues({'quran_theme_mode': 'sepia'});

      final settings = dataOf(await repo.getSettings());

      expect(settings.themeMode, MushafThemeMode.system);
    });

    test('fall back to the printed page for an unknown stored layout', () async {
      SharedPreferences.setMockInitialValues({'quran_layout_mode': 'scroll'});

      final settings = dataOf(await repo.getSettings());

      expect(settings.layoutMode, MushafLayoutMode.page);
    });

    test('fall back to the designed size for an unknown stored size', () async {
      SharedPreferences.setMockInitialValues({'quran_font_scale': 'giant'});

      final settings = dataOf(await repo.getSettings());

      expect(settings.fontScale, QuranFontScale.medium);
    });
  });
}
