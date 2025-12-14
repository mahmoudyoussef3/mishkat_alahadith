import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/core/networking/api_error_model.dart';
import 'package:mishkat_almasabih/features/profile/data/models/stats_model.dart';
import 'package:mishkat_almasabih/features/profile/data/models/user_response_model.dart';
import 'package:mishkat_almasabih/features/profile/data/repos/user_response_repo.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final UserResponseRepo userResponseRepo;
  ProfileCubit(this.userResponseRepo) : super(ProfileInitial());

  Future<void> getUserProfile() async {
    emit(ProfileLoading());
    final result = await userResponseRepo.getUserProfile();
    result.fold(
      (error) => emit(ProfileError(error.getAllErrorMessages() )),
      (user) => emit(ProfileLoaded(user)),
    );
  }


}
