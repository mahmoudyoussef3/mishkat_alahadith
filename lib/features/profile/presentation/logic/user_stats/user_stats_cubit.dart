import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/profile/data/models/stats_model.dart';
import 'package:mishkat_almasabih/features/profile/data/repos/user_response_repo.dart';

part 'user_stats_state.dart';

class UserStatsCubit extends Cubit<UserStatsState> {
  final UserResponseRepo userResponseRepo;
  UserStatsCubit(this.userResponseRepo) : super(UserStatsInitial());
  Future<void> getUserStats() async {
    emit(UserStatsLoading());
    final result = await userResponseRepo.getUserStats();
    result.fold(
      (error) => emit(UserStatsError(error.getAllErrorMessages())),
      (user) => emit(UserStatsLoaded(user)),
    );
  }
}
