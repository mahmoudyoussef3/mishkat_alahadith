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
    // Try cache first
    final cached = await userResponseRepo.getCachedProfile();

    if (cached != null) {
      // Emit cached data immediately
      emit(ProfileLoaded(cached, isFromCache: true, isRefreshing: true));

      // Background refresh
      _backgroundRefresh(cached);
    } else {
      // No cache, fetch from API
      emit(ProfileLoading());
      final result = await userResponseRepo.getUserProfile();
      result.fold(
        (error) => emit(ProfileError(error.getAllErrorMessages())),
        (user) => emit(ProfileLoaded(user)),
      );
    }
  }

  Future<void> _backgroundRefresh(UserResponseModel cached) async {
    final result = await userResponseRepo.getUserProfile();
    result.fold(
      (error) {
        // Background refresh failed, keep cached data
        if (state is ProfileLoaded) {
          emit((state as ProfileLoaded).copyWith(isRefreshing: false));
        }
      },
      (user) {
        emit(ProfileLoaded(user, isFromCache: false, isRefreshing: false));
      },
    );
  }

  /// Force refresh profile (clears cache)
  Future<void> refreshProfile() async {
    emit(ProfileLoading());
    final result = await userResponseRepo.getUserProfile();
    result.fold(
      (error) => emit(ProfileError(error.getAllErrorMessages())),
      (user) => emit(ProfileLoaded(user)),
    );
  }
}
