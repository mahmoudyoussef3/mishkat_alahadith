import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/features/random_ahadith/domain/usecases/get_random_ahadith_use_case.dart';

part 'random_ahadith_state.dart';

class RandomAhadithCubit extends Cubit<RandomAhadithState> {
  final GetRandomAhadithUseCase _getRandomAhadith;

  /// The load under way, which later calls join instead of racing it.
  Future<void>? _inFlight;

  RandomAhadithCubit(this._getRandomAhadith) : super(RandomAhadithInitial());

  /// Loads a new selection. Hadiths already shown stay, marked as
  /// refreshing, and are kept if the new request fails.
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
    result.when(
      success: (hadiths) => emit(RandomAhadithSuccess(hadiths)),
      failure:
          (failure) => emit(
            shown == null
                ? RandomAhaditFailure(failure.message)
                : RandomAhadithSuccess(shown, refreshFailure: failure.message),
          ),
    );
  }
}
