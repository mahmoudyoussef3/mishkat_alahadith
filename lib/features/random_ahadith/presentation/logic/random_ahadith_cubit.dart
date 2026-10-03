import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/features/random_ahadith/domain/usecases/get_random_ahadith_use_case.dart';

part 'random_ahadith_state.dart';

class RandomAhadithCubit extends Cubit<RandomAhadithState> {
  final GetRandomAhadithUseCase _getRandomAhadith;

  RandomAhadithCubit(this._getRandomAhadith) : super(RandomAhadithInitial());

  Future<void> emitRandomStats() async {
    emit(RandomAhadithLoading());

    final result = await _getRandomAhadith();
    result.when(
      success: (hadiths) => emit(RandomAhadithSuccess(hadiths)),
      failure: (failure) => emit(RandomAhaditFailure(failure.message)),
    );
  }
}
