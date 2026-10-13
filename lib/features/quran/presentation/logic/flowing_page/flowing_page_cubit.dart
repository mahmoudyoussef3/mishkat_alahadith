import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_flowing_page.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_flowing_page_use_case.dart';

part 'flowing_page_state.dart';

/// One page of the flowing layout. Each page in the reader has its own, so
/// a swipe loads only the page it lands on and its neighbours.
class FlowingPageCubit extends Cubit<FlowingPageState> {
  final GetFlowingPageUseCase _getFlowingPage;

  /// Counts loads, so only the latest one is shown.
  int _loads = 0;

  FlowingPageCubit(this._getFlowingPage) : super(const FlowingPageLoading());

  /// Loads [page]. A page already shown stays on screen while it reloads,
  /// so the reader keeps their place in it.
  Future<void> load(int page, {required bool includeNaturalMadd}) async {
    final load = ++_loads;
    if (state is! FlowingPageReady) emit(const FlowingPageLoading());
    final result = await _getFlowingPage(
      page,
      includeNaturalMadd: includeNaturalMadd,
    );
    if (isClosed || load != _loads) return;
    emit(switch (result) {
      ApiSuccess(:final data) => FlowingPageReady(data),
      ApiFailure(:final failure) => FlowingPageFailure(failure.message),
    });
  }
}
