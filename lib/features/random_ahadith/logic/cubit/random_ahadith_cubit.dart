import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/random_ahadith/data/models/random_ahadith_model.dart';
import 'package:mishkat_almasabih/features/random_ahadith/data/repos/random_ahadith_repo.dart';

part 'random_ahadith_state.dart';

class RandomAhadithCubit extends Cubit<RandomAhadithState> {
  final RandomAhadithRepo _randomAhadithRepo;
  RandomAhadithCubit(this._randomAhadithRepo) : super(RandomAhadithInitial());

  Future<void> emitRandomStats() async {
    emit(RandomAhadithLoading());

    final result = await _randomAhadithRepo.getRandom();
    result.fold(
      (l) => emit(RandomAhaditFailure(l.getAllErrorMessages() )),
      (r) => emit(RandomAhadithSuccess(r)),
    );
  }
}
