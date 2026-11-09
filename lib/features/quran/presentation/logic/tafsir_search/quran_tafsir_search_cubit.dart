import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition_search.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation_settings.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/quran_study_settings_use_cases.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/search_quran_edition_use_case.dart';

part 'quran_tafsir_search_state.dart';

/// Searches the reader's tafsir online, a page of results at a time.
class QuranTafsirSearchCubit extends Cubit<QuranTafsirSearchState> {
  /// Longer than the mushaf search's: each search here is a request.
  static const Duration defaultDebounce = Duration(milliseconds: 500);

  final GetCommentarySettingsUseCase _getSettings;
  final SaveCommentarySettingsUseCase _saveSettings;
  final SearchQuranEditionUseCase _search;
  final Duration _debounce;

  CommentarySettings? _settings;
  Timer? _pending;

  /// The query whose results may be shown; anything older is dropped.
  String _latestQuery = '';

  /// Counts searches, so a page that arrives for an older one is dropped.
  int _searches = 0;

  QuranTafsirSearchCubit(
    this._getSettings,
    this._saveSettings,
    this._search, {
    Duration debounce = defaultDebounce,
  }) : _debounce = debounce,
       super(QuranTafsirSearchIdle(CommentarySettings.defaults.tafsirId));

  /// Reads which tafsir is searched.
  Future<void> init() async {
    final settings = await _loadSettings();
    if (isClosed) return;
    if (state case QuranTafsirSearchIdle()) {
      emit(QuranTafsirSearchIdle(settings.tafsirId));
    }
  }

  void onQueryChanged(String query) {
    _pending?.cancel();
    _pending = Timer(_debounce, () => search(query));
  }

  Future<void> search(String query) async {
    _pending?.cancel();
    final trimmed = query.trim();
    _latestQuery = trimmed;
    final search = ++_searches;
    final settings = await _loadSettings();
    if (isClosed || search != _searches) return;
    final tafsirId = settings.tafsirId;
    if (!_search.canSearch(trimmed)) {
      emit(QuranTafsirSearchIdle(tafsirId));
      return;
    }

    emit(QuranTafsirSearchLoading(tafsirId, query: trimmed));
    final result = await _search(trimmed, tafsirId);
    if (isClosed || search != _searches || trimmed != _latestQuery) return;
    emit(switch (result) {
      ApiFailure(:final failure) => QuranTafsirSearchFailure(
        tafsirId,
        query: trimmed,
        message: failure.message,
      ),
      ApiSuccess(data: final page) when page.hits.isEmpty && !page.hasMore =>
        QuranTafsirSearchEmpty(tafsirId, query: trimmed),
      ApiSuccess(data: final page) => QuranTafsirSearchSuccess(
        tafsirId,
        query: trimmed,
        hits: page.hits,
        total: page.total,
        nextOffset: page.nextOffset,
        hasMore: page.hasMore,
      ),
    });
  }

  /// The next page of results, once the reader nears the end of this one.
  Future<void> loadMore() async {
    final current = state;
    if (current is! QuranTafsirSearchSuccess ||
        !current.hasMore ||
        current.isLoadingMore) {
      return;
    }
    final search = _searches;
    emit(current.copyWith(isLoadingMore: true, loadMoreFailure: () => null));
    final result = await _search(
      current.query,
      current.tafsirId,
      offset: current.nextOffset,
    );
    final latest = state;
    if (isClosed ||
        search != _searches ||
        latest is! QuranTafsirSearchSuccess) {
      return;
    }
    emit(switch (result) {
      ApiSuccess(data: final page) => latest.copyWith(
        hits: [...latest.hits, ...page.hits],
        nextOffset: page.nextOffset,
        hasMore: page.hasMore,
        isLoadingMore: false,
      ),
      ApiFailure(:final failure) => latest.copyWith(
        isLoadingMore: false,
        loadMoreFailure: () => failure.message,
      ),
    });
  }

  /// Searches [edition] from now on, and again for the words already typed.
  Future<bool> setTafsir(QuranEdition edition) async {
    final current = await _loadSettings();
    final updated = current.copyWith(tafsirId: edition.identifier);
    if (updated == current) return true;
    _settings = updated;
    final saved = await _saveSettings(updated);
    if (isClosed) return false;
    await search(_latestQuery);
    return saved is ApiSuccess;
  }

  void clear() {
    _pending?.cancel();
    _latestQuery = '';
    _searches++;
    emit(QuranTafsirSearchIdle(state.tafsirId));
  }

  Future<CommentarySettings> _loadSettings() async =>
      _settings ??= switch (await _getSettings()) {
        ApiSuccess(:final data) => data,
        ApiFailure() => CommentarySettings.defaults,
      };

  @override
  Future<void> close() {
    _pending?.cancel();
    return super.close();
  }
}
