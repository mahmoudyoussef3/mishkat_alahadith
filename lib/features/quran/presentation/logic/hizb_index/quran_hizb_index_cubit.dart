import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_hizb_quarter.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_hizb_index_use_case.dart';

part 'quran_hizb_index_state.dart';

/// The index of the ahzāb and their quarters. Loaded only when first asked
/// for: the first time, it comes from the network.
class QuranHizbIndexCubit extends Cubit<QuranHizbIndexState> {
  final GetHizbIndexUseCase _getHizbIndex;

  QuranHizbIndexCubit(this._getHizbIndex) : super(const QuranHizbIndexIdle());

  /// Loads the index unless it is loaded or loading.
  Future<void> loadIfNeeded() async {
    if (state is QuranHizbIndexLoaded || state is QuranHizbIndexLoading) return;
    await load();
  }

  Future<void> load() async {
    emit(const QuranHizbIndexLoading());
    final result = await _getHizbIndex();
    if (isClosed) return;
    emit(switch (result) {
      ApiSuccess(:final data) => QuranHizbIndexLoaded(data),
      ApiFailure(:final failure) => QuranHizbIndexFailure(failure.message),
    });
  }
}
