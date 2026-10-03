import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_search_results.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/search_quran_use_case.dart';

part 'quran_search_state.dart';

class QuranSearchCubit extends Cubit<QuranSearchState> {
  static const Duration defaultDebounce = Duration(milliseconds: 300);

  final SearchQuranUseCase _search;
  final Duration _debounce;

  /// The query whose results may be shown; anything older is dropped.
  String _latestQuery = '';
  Timer? _pending;

  QuranSearchCubit(this._search, {Duration debounce = defaultDebounce})
    : _debounce = debounce,
      super(const QuranSearchIdle());

  /// Searches once typing pauses, so a word typed letter by letter scans the
  /// mushaf once rather than once per letter.
  void onQueryChanged(String query) {
    _pending?.cancel();
    _pending = Timer(_debounce, () => search(query));
  }

  /// Searches at once — for a submitted query, a suggestion or a retry.
  Future<void> search(String query) async {
    _pending?.cancel();
    final trimmed = query.trim();
    _latestQuery = trimmed;
    if (!_search.canSearch(trimmed)) {
      emit(const QuranSearchIdle());
      return;
    }

    emit(QuranSearchLoading(trimmed));
    final result = await _search(trimmed);
    if (isClosed || trimmed != _latestQuery) return;

    emit(switch (result) {
      ApiFailure(:final failure) => QuranSearchFailure(
        query: trimmed,
        message: failure.message,
      ),
      ApiSuccess(:final data) when data.isEmpty => QuranSearchEmpty(trimmed),
      ApiSuccess(:final data) => QuranSearchSuccess(data),
    });
  }

  void clear() {
    _pending?.cancel();
    _latestQuery = '';
    emit(const QuranSearchIdle());
  }

  @override
  Future<void> close() {
    _pending?.cancel();
    return super.close();
  }
}
