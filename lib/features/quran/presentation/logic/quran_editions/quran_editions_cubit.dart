import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/filter_quran_editions_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_quran_editions_use_case.dart';

part 'quran_editions_state.dart';

/// The reciters, tafsirs or translations to pick from.
class QuranEditionsCubit extends Cubit<QuranEditionsState> {
  final GetQuranEditionsUseCase _getEditions;
  final FilterQuranEditionsUseCase _filter;

  QuranEditionsCubit(this._getEditions, this._filter)
    : super(const QuranEditionsLoading());

  Future<void> load(QuranEditionType type) async {
    emit(const QuranEditionsLoading());
    final result = await _getEditions(type);
    if (isClosed) return;
    emit(switch (result) {
      ApiFailure(:final failure) => QuranEditionsFailure(failure.message),
      ApiSuccess(:final data) => QuranEditionsLoaded(
        editions: data,
        visible: data,
        query: '',
      ),
    });
  }

  void filter(String query) {
    final current = state;
    if (current is! QuranEditionsLoaded) return;
    emit(
      QuranEditionsLoaded(
        editions: current.editions,
        visible: _filter(current.editions, query),
        query: query,
      ),
    );
  }
}
