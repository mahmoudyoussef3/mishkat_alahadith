import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/ayah_details.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/mushaf_reader_settings.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/tajweed_info.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_mushaf_settings_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_page_info_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_page_tajweed_counts_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_quran_bookmarks_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_surahs_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/save_last_read_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/save_mushaf_settings_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/toggle_quran_bookmark_use_case.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';

import '../quran_fakes.dart';

const _pageOneCounts = [
  TajweedRuleCount(ruleKey: 'ikhfa', count: 3),
  TajweedRuleCount(ruleKey: 'ghunna', count: 1),
];
const _pageOneCountsWithMadd = [
  TajweedRuleCount(ruleKey: 'maddNatural', count: 9),
  ..._pageOneCounts,
];

MushafReaderCubit _cubit(FakeQuranRepo quran, FakeQuranReadingRepo reading) =>
    MushafReaderCubit(
      GetMushafSettingsUseCase(reading),
      SaveMushafSettingsUseCase(reading),
      GetSurahsUseCase(quran),
      GetPageInfoUseCase(quran),
      GetPageTajweedCountsUseCase(quran),
      GetQuranBookmarksUseCase(reading),
      ToggleQuranBookmarkUseCase(reading),
      SaveLastReadUseCase(reading),
    );

/// A repo whose page 1 counts depend on whether the natural madd is asked for.
class _CountingRepo extends FakeQuranRepo {
  @override
  Future<ApiResult<List<TajweedRuleCount>>> getPageTajweedCounts(
    int page, {
    required bool includeNaturalMadd,
  }) {
    pageCounts = {
      1: includeNaturalMadd ? _pageOneCountsWithMadd : _pageOneCounts,
    };
    return super.getPageTajweedCounts(
      page,
      includeNaturalMadd: includeNaturalMadd,
    );
  }
}

MushafReaderReady _ready(MushafReaderCubit cubit) =>
    cubit.state as MushafReaderReady;

void main() {
  late FakeQuranRepo quran;
  late FakeQuranReadingRepo reading;

  setUp(() {
    quran = FakeQuranRepo(pageCounts: {1: _pageOneCounts});
    reading = FakeQuranReadingRepo();
  });

  group('init', () {
    test('opens on the requested page with the saved settings', () async {
      reading.settings = const MushafReaderSettings(
        themeMode: MushafThemeMode.night,
      );
      final cubit = _cubit(quran, reading);

      await cubit.init(initialPage: 22);

      expect(_ready(cubit).page, 22);
      expect(_ready(cubit).settings.themeMode, MushafThemeMode.night);
      await cubit.close();
    });

    test('clamps a page beyond the mushaf to the last page', () async {
      final cubit = _cubit(quran, reading);

      await cubit.init(initialPage: 9000);

      expect(_ready(cubit).page, 604);
      await cubit.close();
    });

    test('highlights the ayah it was opened for', () async {
      final cubit = _cubit(quran, reading);

      await cubit.init(initialPage: 1, highlightAyahId: 2);

      expect(_ready(cubit).selectedAyahId, 2);
      await cubit.close();
    });

    test('records the opening page as the last read', () async {
      final cubit = _cubit(quran, reading);

      await cubit.init(initialPage: 22);
      await pumpEventQueue();

      expect(reading.savedPages, [22]);
      await cubit.close();
    });

    test('loads the page header details', () async {
      final cubit = _cubit(quran, reading);

      await cubit.init(initialPage: 22);

      expect(_ready(cubit).pageInfo?.juz, 2);
      await cubit.close();
    });

    test('uses the default settings when they cannot be read', () async {
      reading.failReads = true;
      final cubit = _cubit(quran, reading);

      await cubit.init(initialPage: 1);

      expect(_ready(cubit).settings, MushafReaderSettings.defaults);
      await cubit.close();
    });

    test('fails when the surah table cannot be loaded', () async {
      quran.failSurahs = true;
      final cubit = _cubit(quran, reading);

      await cubit.init(initialPage: 1);

      expect(cubit.state, isA<MushafReaderFailure>());
      await cubit.close();
    });

    test('loads the page rule counts when tajweed is on', () async {
      reading.settings = const MushafReaderSettings(tajweedEnabled: true);
      final cubit = _cubit(quran, reading);

      await cubit.init(initialPage: 1);

      expect(_ready(cubit).ruleCounts, _pageOneCounts);
      await cubit.close();
    });
  });

  group('turning the page', () {
    test('moves to the page and records it as the last read', () async {
      final cubit = _cubit(quran, reading);
      await cubit.init(initialPage: 1);

      cubit.onPageChanged(2);
      await pumpEventQueue();

      expect(_ready(cubit).page, 2);
      expect(reading.savedPages.last, 2);
      await cubit.close();
    });

    test('ends the rule walk and the selection', () async {
      reading.settings = const MushafReaderSettings(tajweedEnabled: true);
      final cubit = _cubit(quran, reading);
      await cubit.init(initialPage: 1, highlightAyahId: 1);
      await cubit.followRule('ikhfa');

      cubit.onPageChanged(2);

      expect(_ready(cubit).focusRuleKey, isNull);
      expect(_ready(cubit).selectedAyahId, isNull);
      await cubit.close();
    });

    test('ignores details that arrive for a page already left', () async {
      final cubit = _cubit(quran, reading);
      await cubit.init(initialPage: 1);
      final slowPage = Completer<void>();
      quran.pageGates[2] = slowPage;

      cubit.onPageChanged(2);
      cubit.onPageChanged(22);
      await pumpEventQueue();
      slowPage.complete();
      await pumpEventQueue();

      expect(_ready(cubit).pageInfo?.page, 22);
      await cubit.close();
    });
  });

  group('settings', () {
    test('turning tajweed on saves it and loads the page rules', () async {
      final cubit = _cubit(quran, reading);
      await cubit.init(initialPage: 1);

      final saved = await cubit.setTajweedEnabled(true);

      expect(saved, isTrue);
      expect(reading.settings.tajweedEnabled, isTrue);
      expect(_ready(cubit).ruleCounts, _pageOneCounts);
      await cubit.close();
    });

    test('turning the natural madd on recounts with it included', () async {
      reading.settings = const MushafReaderSettings(tajweedEnabled: true);
      final cubit = _cubit(_CountingRepo(), reading);
      await cubit.init(initialPage: 1);

      await cubit.setNaturalMaddEnabled(true);

      expect(_ready(cubit).ruleCounts.first.ruleKey, 'maddNatural');
      await cubit.close();
    });

    test('changing the theme does not recount the rules', () async {
      reading.settings = const MushafReaderSettings(tajweedEnabled: true);
      final cubit = _cubit(quran, reading);
      await cubit.init(initialPage: 1);
      final before = quran.countRequests.length;

      await cubit.setThemeMode(MushafThemeMode.night);

      expect(_ready(cubit).settings.themeMode, MushafThemeMode.night);
      expect(quran.countRequests, hasLength(before));
      await cubit.close();
    });

    test('a setting that cannot be saved still applies now', () async {
      final cubit = _cubit(quran, reading);
      await cubit.init(initialPage: 1);
      reading.failWrites = true;

      final saved = await cubit.setTajweedEnabled(true);

      expect(saved, isFalse);
      expect(_ready(cubit).settings.tajweedEnabled, isTrue);
      await cubit.close();
    });
  });

  group('following a rule', () {
    test('switches the colouring on and frames the first occurrence', () async {
      final cubit = _cubit(quran, reading);
      await cubit.init(initialPage: 1);

      await cubit.followRule('ikhfa');

      expect(_ready(cubit).settings.tajweedEnabled, isTrue);
      expect(_ready(cubit).focusRuleKey, 'ikhfa');
      expect(_ready(cubit).focusIndex, 0);
      expect(_ready(cubit).focusTotal, 3);
      await cubit.close();
    });

    test('switches the natural madd on to follow it', () async {
      reading.settings = const MushafReaderSettings(tajweedEnabled: true);
      final cubit = _cubit(_CountingRepo(), reading);
      await cubit.init(initialPage: 1);

      await cubit.followRule('maddNatural');

      expect(_ready(cubit).settings.naturalMaddEnabled, isTrue);
      expect(_ready(cubit).isFocusing, isTrue);
      await cubit.close();
    });

    test('next wraps from the last occurrence to the first', () async {
      final cubit = _cubit(quran, reading);
      await cubit.init(initialPage: 1);
      await cubit.followRule('ikhfa');

      cubit
        ..focusNext()
        ..focusNext()
        ..focusNext();

      expect(_ready(cubit).focusIndex, 0);
      await cubit.close();
    });

    test('previous wraps from the first occurrence to the last', () async {
      final cubit = _cubit(quran, reading);
      await cubit.init(initialPage: 1);
      await cubit.followRule('ikhfa');

      cubit.focusPrevious();

      expect(_ready(cubit).focusIndex, 2);
      await cubit.close();
    });

    test(
      'reports that a rule absent from the page cannot be followed',
      () async {
        final cubit = _cubit(quran, reading);
        await cubit.init(initialPage: 1);

        final following = await cubit.followRule('iqlab');

        expect(following, isFalse);
        expect(_ready(cubit).isFocusing, isFalse);
        await cubit.close();
      },
    );

    test('clearFocus ends the walk', () async {
      final cubit = _cubit(quran, reading);
      await cubit.init(initialPage: 1);
      await cubit.followRule('ikhfa');

      cubit.clearFocus();

      expect(_ready(cubit).isFocusing, isFalse);
      await cubit.close();
    });
  });

  group('rule counts', () {
    test('a failed count is flagged instead of showing no rules', () async {
      reading.settings = const MushafReaderSettings(tajweedEnabled: true);
      quran.failCounts = true;
      final cubit = _cubit(quran, reading);

      await cubit.init(initialPage: 1);

      expect(_ready(cubit).ruleCountsFailed, isTrue);
      await cubit.close();
    });

    test('retrying after a failed count loads the rules', () async {
      reading.settings = const MushafReaderSettings(tajweedEnabled: true);
      quran.failCounts = true;
      final cubit = _cubit(quran, reading);
      await cubit.init(initialPage: 1);
      quran.failCounts = false;

      await cubit.retryRuleCounts();

      expect(_ready(cubit).ruleCountsFailed, isFalse);
      expect(_ready(cubit).ruleCounts, _pageOneCounts);
      await cubit.close();
    });
  });

  group('selection', () {
    test('selectAyah highlights the ayah', () async {
      final cubit = _cubit(quran, reading);
      await cubit.init(initialPage: 1);

      cubit.selectAyah(2);

      expect(_ready(cubit).selectedAyahId, 2);
      await cubit.close();
    });

    test('clearSelection removes the highlight', () async {
      final cubit = _cubit(quran, reading);
      await cubit.init(initialPage: 1, highlightAyahId: 2);

      cubit.clearSelection();

      expect(_ready(cubit).selectedAyahId, isNull);
      await cubit.close();
    });
  });

  group('bookmarks', () {
    test('bookmarking the page marks it as bookmarked', () async {
      final cubit = _cubit(quran, reading);
      await cubit.init(initialPage: 22);

      final result = await cubit.togglePageBookmark();

      expect(result, BookmarkToggleResult.added);
      expect(_ready(cubit).isPageBookmarked, isTrue);
      expect(reading.bookmarks.single.surahName, 'البقرة');
      await cubit.close();
    });

    test('bookmarking a bookmarked page removes the bookmark', () async {
      reading.bookmarks = [pageBookmark(22)];
      final cubit = _cubit(quran, reading);
      await cubit.init(initialPage: 22);

      final result = await cubit.togglePageBookmark();

      expect(result, BookmarkToggleResult.removed);
      expect(_ready(cubit).isPageBookmarked, isFalse);
      await cubit.close();
    });

    test('reports a bookmark that could not be saved', () async {
      final cubit = _cubit(quran, reading);
      await cubit.init(initialPage: 22);
      reading.failWrites = true;

      expect(await cubit.togglePageBookmark(), BookmarkToggleResult.failed);
      await cubit.close();
    });

    test('bookmarking an ayah marks that ayah only', () async {
      final cubit = _cubit(quran, reading);
      await cubit.init(initialPage: 1);

      await cubit.toggleAyahBookmark(
        const AyahDetails(ayah: hamd, surah: fatihah, tajweed: []),
      );

      expect(_ready(cubit).isAyahBookmarked(2), isTrue);
      expect(_ready(cubit).isPageBookmarked, isFalse);
      await cubit.close();
    });

    test('reloadBookmarks picks up a bookmark removed elsewhere', () async {
      reading.bookmarks = [pageBookmark(22)];
      final cubit = _cubit(quran, reading);
      await cubit.init(initialPage: 22);
      reading.bookmarks = [];

      await cubit.reloadBookmarks();

      expect(_ready(cubit).isPageBookmarked, isFalse);
      await cubit.close();
    });
  });
}
