import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/random_ahadith/domain/usecases/get_cached_random_ahadith_use_case.dart';
import 'package:mishkat_almasabih/features/random_ahadith/domain/usecases/get_random_ahadith_use_case.dart';

part 'random_ahadith_state.dart';

class RandomAhadithCubit extends Cubit<RandomAhadithState> {
  final GetRandomAhadithUseCase _getRandomAhadith;
  final GetCachedRandomAhadithUseCase _getCachedRandomAhadith;

  /// The load under way, which later calls join instead of racing it.
  Future<void>? _inFlight;

  RandomAhadithCubit(this._getRandomAhadith, this._getCachedRandomAhadith)
    : super(RandomAhadithInitial());

  /// Loads a new selection. Hadiths already shown stay, marked as
  /// refreshing, and are kept if the new request fails; with none shown
  /// yet, the last selection fetched stands in, so the section still
  /// works offline.
  Future<void> emitRandomStats() =>
      _inFlight ??= _load().whenComplete(() => _inFlight = null);

  Future<void> _load() async {
    final shown = switch (state) {
      RandomAhadithSuccess(:final hadiths) => hadiths,
      _ => null,
    };
    emit(
      shown == null
          ? RandomAhadithLoading()
          : RandomAhadithSuccess(shown, refreshing: true),
    );

    final result = await _getRandomAhadith();
    switch (result) {
      case ApiSuccess(:final data):
        emit(RandomAhadithSuccess(data));
      case ApiFailure(:final failure) when shown != null:
        emit(RandomAhadithSuccess(shown, refreshFailure: failure.message));
      case ApiFailure(:final failure):
        final kept = await _getCachedRandomAhadith();
        if (isClosed) return;
        emit(
          kept == null || kept.isEmpty
              ? RandomAhaditFailure(failure.message)
              : RandomAhadithSuccess(kept, refreshFailure: failure.message),
        );
    }
  }
}
