import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/features/authentication/session/domain/usecases/is_signed_in_use_case.dart';
import 'package:mishkat_almasabih/features/search/search_history/domain/entities/search_history_entry.dart';
import 'package:mishkat_almasabih/features/search/search_history/domain/usecases/add_search_history_entry_use_case.dart';
import 'package:mishkat_almasabih/features/search/search_history/domain/usecases/clear_search_history_use_case.dart';
import 'package:mishkat_almasabih/features/search/search_history/domain/usecases/delete_search_history_entry_use_case.dart';
import 'package:mishkat_almasabih/features/search/search_history/domain/usecases/get_search_history_use_case.dart';

part 'search_history_state.dart';

class SearchHistoryCubit extends Cubit<SearchHistoryState> {
  final IsSignedInUseCase _isSignedIn;
  final GetSearchHistoryUseCase _getHistory;
  final AddSearchHistoryEntryUseCase _addEntry;
  final DeleteSearchHistoryEntryUseCase _deleteEntry;
  final ClearSearchHistoryUseCase _clearHistory;
  bool _initialized = false;

  SearchHistoryCubit(
    this._isSignedIn,
    this._getHistory,
    this._addEntry,
    this._deleteEntry,
    this._clearHistory,
  ) : super(SearchHistoryInitial());

  Future<void> init() async {
    if (!await _isSignedIn()) {
      emit(SearchHistoryError('Unauthorized: No token found'));
    } else {
      _initialized = true;
      await fetchHistory();
    }
  }

  bool get isReady => _initialized;

  Future<void> fetchHistory() async {
    if (!isReady) {
      emit(SearchHistoryError('Unauthorized or Cubit not initialized'));
      return;
    }

    emit(SearchHistoryLoading());

    final result = await _getHistory();

    result.when(
      success: (history) => emit(SearchHistorySuccess(history)),
      failure: (failure) => emit(SearchHistoryError(failure.message)),
    );
  }

  Future<void> addSearchItem(NewSearchHistoryEntry item) async {
    if (!isReady) {
      emit(SearchHistoryError('Unauthorized or Cubit not initialized'));
      return;
    }

    emit(SearchHistoryLoading());

    final result = await _addEntry(item);

    await result.when(
      success: (_) async => await fetchHistory(),
      failure: (failure) async => emit(SearchHistoryError(failure.message)),
    );
  }

  Future<void> deleteSearchItem(int id) async {
    if (!isReady) {
      emit(SearchHistoryError('Unauthorized or Cubit not initialized'));
      return;
    }

    emit(SearchHistoryLoading());

    final result = await _deleteEntry(id);

    await result.when(
      success: (_) async => await fetchHistory(),
      failure: (failure) async => emit(SearchHistoryError(failure.message)),
    );
  }

  Future<void> clearAllHistory() async {
    if (!isReady) {
      emit(SearchHistoryError('Unauthorized or Cubit not initialized'));
      return;
    }

    emit(SearchHistoryLoading());

    final result = await _clearHistory();

    await result.when(
      success: (_) async => emit(SearchHistorySuccess([])),
      failure: (failure) async => emit(SearchHistoryError(failure.message)),
    );
  }
}
