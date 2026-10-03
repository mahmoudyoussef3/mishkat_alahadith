import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/random_ahadith/data/models/random_ahadith_model.dart';
import 'package:mishkat_almasabih/features/random_ahadith/data/repos/random_ahadith_repo.dart';
import 'package:mishkat_almasabih/core/networking/network_info.dart';

part 'random_ahadith_state.dart';

class RandomAhadithCubit extends Cubit<RandomAhadithState> {
  final RandomAhadithRepo _randomAhadithRepo;
  final NetworkInfo _networkInfo;

  RandomAhadithCubit(this._randomAhadithRepo, this._networkInfo) : super(RandomAhadithInitial());

  Future<void> emitRandomStats() async {
    final hasInternet = await _networkInfo.isConnected;
    if (!hasInternet) {
      emit(RandomAhaditFailure('لا يوجد اتصال بالإنترنت'));
      return;
    }

    emit(RandomAhadithLoading());

    final result = await _randomAhadithRepo.getRandom();
    result.fold(
      (l) => emit(RandomAhaditFailure(l.getAllErrorMessages())),
      (r) => emit(RandomAhadithSuccess(r)),
    );
  }
}
