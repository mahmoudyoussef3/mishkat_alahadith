import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/features/profile/domain/entities/user_stats.dart';
import 'package:mishkat_almasabih/features/profile/domain/usecases/get_user_stats_use_case.dart';

part 'user_stats_state.dart';

class UserStatsCubit extends Cubit<UserStatsState> {
  final GetUserStatsUseCase _getUserStats;
  UserStatsCubit(this._getUserStats) : super(UserStatsInitial());
  Future<void> getUserStats() async {
    emit(UserStatsLoading());
    final result = await _getUserStats();
    result.when(
      success: (stats) => emit(UserStatsLoaded(stats)),
      failure: (failure) => emit(UserStatsError(failure.message)),
    );
  }
}
