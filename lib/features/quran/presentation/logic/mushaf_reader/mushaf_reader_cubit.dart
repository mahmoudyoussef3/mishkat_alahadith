import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/ayah_details.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/mushaf_reader_settings.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_bookmark.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_metrics.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_page_info.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_surah.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/tajweed_info.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_mushaf_settings_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_page_info_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_page_tajweed_counts_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_quran_bookmarks_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_surahs_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/save_last_read_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/save_mushaf_settings_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/toggle_quran_bookmark_use_case.dart';

part 'mushaf_reader_state.dart';

class MushafReaderCubit extends Cubit<MushafReaderState> {
  final GetMushafSettingsUseCase _getSettings;
  final SaveMushafSettingsUseCase _saveSettings;
  final GetSurahsUseCase _getSurahs;
  final GetPageInfoUseCase _getPageInfo;
  final GetPageTajweedCountsUseCase _getPageTajweedCounts;
  final GetQuranBookmarksUseCase _getBookmarks;
  final ToggleQuranBookmarkUseCase _toggleBookmark;
  final SaveLastReadUseCase _saveLastRead;

  MushafReaderCubit(
    this._getSettings,
    this._saveSettings,
    this._getSurahs,
    this._getPageInfo,
    this._getPageTajweedCounts,
    this._getBookmarks,
    this._toggleBookmark,
    this._saveLastRead,
  ) : super(const MushafReaderLoading());

  /// [highlightAyahId] washes one ayah on arrival — used when opening the
  /// mushaf from a search hit or an ayah bookmark. [surahNumber] is the surah
  /// opened, read even on a page that opens with the surah before it.
  Future<void> init({
    required int initialPage,
    int? highlightAyahId,
    int? surahNumber,
  }) async {
    emit(const MushafReaderLoading());
    final page = QuranMetrics.clampPage(initialPage);
    final (settingsResult, surahsResult, bookmarksResult) =
        await (_getSettings(), _getSurahs(), _getBookmarks()).wait;
    if (isClosed) return;

    switch (surahsResult) {
      case ApiFailure(:final failure):
        emit(MushafReaderFailure(failure.message));
      case ApiSuccess(data: final surahs):
        emit(
          MushafReaderReady(
            page: page,
            // A reader whose preferences cannot be read still gets a page.
            settings: switch (settingsResult) {
              ApiSuccess(:final data) => data,
              ApiFailure() => MushafReaderSettings.defaults,
            },
            surahs: surahs,
            readingSurah: QuranSurah.readingAt(
              surahs,
              page,
              current: QuranSurah.numbered(surahs, surahNumber),
            ),
            bookmarks: switch (bookmarksResult) {
              ApiSuccess(:final data) => data,
              ApiFailure() => const [],
            },
            selectedAyahId: highlightAyahId,
          ),
        );
        unawaited(_recordLastRead(page));
        await Future.wait([_loadPageInfo(page), _loadRuleCounts()]);
    }
  }

  void onPageChanged(int page) {
    final current = state;
    if (current is! MushafReaderReady || current.page == page) return;
    // Focus positions and the selection belong to their page.
    emit(
      current.copyWith(
        page: page,
        readingSurah:
            () => QuranSurah.readingAt(
              current.surahs,
              page,
              current: current.readingSurah,
            ),
        pageInfo: () => null,
        ruleCounts: const [],
        ruleCountsFailed: false,
        focusRuleKey: () => null,
        focusIndex: 0,
        selectedAyahId: () => null,
      ),
    );
    unawaited(_recordLastRead(page));
    unawaited(_loadPageInfo(page));
    unawaited(_loadRuleCounts());
  }

  /// Reads [surahNumber] from here on, as when it is picked from the index
  /// and its page turned to. Ignored unless the surah is on the current page.
  void readSurah(int surahNumber) {
    final current = state;
    if (current is! MushafReaderReady) return;
    final surah = QuranSurah.numbered(current.surahs, surahNumber);
    if (surah == null ||
        !surah.containsPage(current.page) ||
        surah == current.readingSurah) {
      return;
    }
    emit(current.copyWith(readingSurah: () => surah));
  }

  // ── settings ────────────────────────────────────────────────────────────

  Future<bool> setTajweedEnabled(bool enabled) =>
      _updateSettings((s) => s.copyWith(tajweedEnabled: enabled));

  Future<bool> setNaturalMaddEnabled(bool enabled) =>
      _updateSettings((s) => s.copyWith(naturalMaddEnabled: enabled));

  Future<bool> setThemeMode(MushafThemeMode mode) =>
      _updateSettings((s) => s.copyWith(themeMode: mode));

  Future<bool> setLayoutMode(MushafLayoutMode mode) =>
      _updateSettings((s) => s.copyWith(layoutMode: mode));

  Future<bool> setFontScale(QuranFontScale scale) =>
      _updateSettings((s) => s.copyWith(fontScale: scale));

  /// Applies the change at once and persists it; `false` if it could not be
  /// saved for next time.
  Future<bool> _updateSettings(
    MushafReaderSettings Function(MushafReaderSettings) change,
  ) async {
    final current = state;
    if (current is! MushafReaderReady) return false;
    final updated = change(current.settings);
    if (updated == current.settings) return true;

    final colouringChanged =
        updated.tajweedEnabled != current.settings.tajweedEnabled ||
        updated.naturalMaddEnabled != current.settings.naturalMaddEnabled;
    emit(
      colouringChanged
          ? current.copyWith(
            settings: updated,
            ruleCounts: const [],
            ruleCountsFailed: false,
            focusRuleKey: () => null,
            focusIndex: 0,
          )
          : current.copyWith(settings: updated),
    );

    final saved = await _saveSettings(updated);
    if (colouringChanged) await _loadRuleCounts();
    return saved is ApiSuccess;
  }

  // ── tajweed focus ───────────────────────────────────────────────────────

  /// Starts stepping through [ruleKey] on this page, switching the colouring
  /// on first if the rule would not otherwise be drawn.
  ///
  /// `false` when there is nothing to step through — the rule does not occur
  /// on this page, or the page's rules could not be counted.
  Future<bool> followRule(String ruleKey) async {
    final current = state;
    if (current is! MushafReaderReady) return false;
    final needsNaturalMadd =
        ruleKey == TajweedRuleKeys.naturalMadd &&
        !current.settings.naturalMaddEnabled;
    if (!current.settings.tajweedEnabled || needsNaturalMadd) {
      await _updateSettings(
        (s) => s.copyWith(
          tajweedEnabled: true,
          naturalMaddEnabled: needsNaturalMadd ? true : null,
        ),
      );
    }
    final latest = state;
    if (isClosed || latest is! MushafReaderReady) return false;
    final focused = latest.copyWith(
      focusRuleKey: () => ruleKey,
      focusIndex: 0,
      selectedAyahId: () => null,
    );
    emit(focused);
    return focused.isFocusing;
  }

  void focusNext() => _moveFocus(1);

  void focusPrevious() => _moveFocus(-1);

  void _moveFocus(int step) {
    final current = state;
    if (current is! MushafReaderReady) return;
    final total = current.focusTotal;
    if (total == 0) return;
    emit(current.copyWith(focusIndex: (current.focusIndex + step) % total));
  }

  void clearFocus() {
    final current = state;
    if (current is! MushafReaderReady || current.focusRuleKey == null) return;
    emit(current.copyWith(focusRuleKey: () => null, focusIndex: 0));
  }

  // ── ayah selection ──────────────────────────────────────────────────────

  void selectAyah(int ayahId) {
    final current = state;
    if (current is! MushafReaderReady) return;
    emit(current.copyWith(selectedAyahId: () => ayahId));
  }

  void clearSelection() {
    final current = state;
    if (current is! MushafReaderReady || current.selectedAyahId == null) return;
    emit(current.copyWith(selectedAyahId: () => null));
  }

  // ── bookmarks ───────────────────────────────────────────────────────────

  Future<BookmarkToggleResult> togglePageBookmark() async {
    final current = state;
    if (current is! MushafReaderReady) return BookmarkToggleResult.failed;
    final surah = current.headerSurah;
    if (surah == null) return BookmarkToggleResult.failed;
    return _afterToggle(
      await _toggleBookmark(
        page: current.page,
        surahNumber: surah.number,
        surahName: surah.nameArabic,
      ),
    );
  }

  Future<BookmarkToggleResult> toggleAyahBookmark(AyahDetails details) async {
    return _afterToggle(
      await _toggleBookmark(
        page: details.ayah.page,
        surahNumber: details.surah.number,
        surahName: details.surah.nameArabic,
        ayahId: details.ayah.id,
        ayahNumber: details.ayah.number,
      ),
    );
  }

  /// Re-reads the bookmarks after they may have changed elsewhere, such as
  /// from the index sheet.
  Future<void> reloadBookmarks() async {
    final bookmarks = await _getBookmarks();
    final latest = state;
    if (isClosed || latest is! MushafReaderReady) return;
    switch (bookmarks) {
      case ApiSuccess(:final data):
        emit(latest.copyWith(bookmarks: data));
      case ApiFailure(:final failure):
        // The last list read stays on screen; the next change re-reads it.
        _logFailure('reload bookmarks', failure);
    }
  }

  Future<BookmarkToggleResult> _afterToggle(ApiResult<bool> result) async {
    switch (result) {
      case ApiFailure():
        return BookmarkToggleResult.failed;
      case ApiSuccess(data: final added):
        await reloadBookmarks();
        return added
            ? BookmarkToggleResult.added
            : BookmarkToggleResult.removed;
    }
  }

  // ── page data ───────────────────────────────────────────────────────────

  Future<void> _loadPageInfo(int page) async {
    final result = await _getPageInfo(page);
    final latest = state;
    if (isClosed || latest is! MushafReaderReady || latest.page != page) return;
    // Without page info the header falls back to the surah table, so a
    // failure here costs the juz label and nothing else.
    if (result case ApiSuccess(:final data)) {
      emit(latest.copyWith(pageInfo: () => data));
    }
  }

  Future<void> _loadRuleCounts() async {
    final current = state;
    if (current is! MushafReaderReady || !current.settings.tajweedEnabled) {
      return;
    }
    final page = current.page;
    final settings = current.settings;
    final result = await _getPageTajweedCounts(
      page,
      includeNaturalMadd: settings.naturalMaddEnabled,
    );
    final latest = state;
    if (isClosed ||
        latest is! MushafReaderReady ||
        latest.page != page ||
        latest.settings != settings) {
      return;
    }
    emit(switch (result) {
      ApiSuccess(:final data) => latest.copyWith(
        ruleCounts: data,
        ruleCountsFailed: false,
      ),
      ApiFailure() => latest.copyWith(
        ruleCounts: const [],
        ruleCountsFailed: true,
      ),
    });
  }

  /// Counts the current page's rules again after a failure.
  Future<void> retryRuleCounts() => _loadRuleCounts();

  /// Remembers the page for «continue reading». A failed write is not worth
  /// interrupting the reader for — the next page turn writes again — so it is
  /// logged rather than shown.
  Future<void> _recordLastRead(int page) async {
    final result = await _saveLastRead(page);
    if (result case ApiFailure(:final failure)) {
      _logFailure('save last read page $page', failure);
    }
  }

  void _logFailure(String action, Object failure) {
    developer.log('Could not $action: $failure', name: 'MushafReaderCubit');
  }
}
