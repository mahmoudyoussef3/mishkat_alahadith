import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/features/home/data/models/search_history_models.dart';
import 'package:mishkat_almasabih/features/search/search_screen/data/repos/shared_pref_history_item_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'search_history_state.dart';

class SearchHistoryCubit extends Cubit<SearchHistoryState> {
  final SearchHistoryRepo repo;
  String? _token;
  bool _initialized = false;

  SearchHistoryCubit(this.repo) : super(SearchHistoryInitial());

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    if (_token == null) {
      emit(SearchHistoryError('Unauthorized: No token found'));
    } else {
      _initialized = true;
      await fetchHistory();
    }
  }

  bool get isReady => _initialized && _token != null;

  Future<void> fetchHistory(
 
  ) async {
    if (!isReady) {
      emit(SearchHistoryError('Unauthorized or Cubit not initialized'));
      return;
    }

    emit(SearchHistoryLoading());

    final result = await repo.getSearchHistory(
      token: _token!,
 
    );

    result.fold(
      (error) => emit(SearchHistoryError(error.toString())),
      (history) => emit(SearchHistorySuccess(history)),
    );
  }

  Future<void> addSearchItem(AddSearchRequest item) async {
    if (!isReady) {
      emit(SearchHistoryError('Unauthorized or Cubit not initialized'));
      return;
    }

    emit(SearchHistoryLoading());

    final result = await repo.addSearch(token: _token!, body: item);

    await result.fold(
      (error) async => emit(SearchHistoryError(error.toString())),
      (_) async => await fetchHistory(),
    );
  }

  Future<void> deleteSearchItem(int id) async {
    if (!isReady) {
      emit(SearchHistoryError('Unauthorized or Cubit not initialized'));
      return;
    }

    emit(SearchHistoryLoading());

    final result = await repo.deleteSearch(token: _token!, searchId: id);

    await result.fold(
      (error) async => emit(SearchHistoryError(error.toString())),
      (_) async => await fetchHistory(),
    );
  }

  Future<void> clearAllHistory() async {
    if (!isReady) {
      emit(SearchHistoryError('Unauthorized or Cubit not initialized'));
      return;
    }

    emit(SearchHistoryLoading());

    final result = await repo.deleteAllSearch(
      token: _token!,
      body: {"confirm": true},
    );

    await result.fold(
      (error) async => emit(SearchHistoryError(error.toString())),
      (_) async => emit(SearchHistorySuccess([])),
    );
  }


}
