import 'dart:developer';
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
    log('👤 [ProfileCubit] Fetching user profile');
    
    // Try cache first
    final cached = await userResponseRepo.getCachedProfile();

    if (cached != null) {
      log('✅ [ProfileCubit] CACHE HIT - user: ${cached.username ?? "N/A"}');
      // Emit cached data immediately
      emit(ProfileLoaded(cached, isFromCache: true, isRefreshing: true));

      // Background refresh
      _backgroundRefresh(cached);
    } else {
      log('❌ [ProfileCubit] CACHE MISS - Fetching from API');
      // No cache, fetch from API
      emit(ProfileLoading());
      final result = await userResponseRepo.getUserProfile();
      result.fold(
        (error) {
          log('🔴 [ProfileCubit] API ERROR: ${error.getAllErrorMessages()}');
          emit(ProfileError(error.getAllErrorMessages()));
        },
        (user) {
          log('🟢 [ProfileCubit] API SUCCESS - user: ${user.username ?? "N/A"}');
          emit(ProfileLoaded(user));
        },
      );
    }
  }

  Future<void> _backgroundRefresh(UserResponseModel cached) async {
    log('🔄 [ProfileCubit] Background refresh started');
    final result = await userResponseRepo.getUserProfile();
    result.fold(
      (error) {
        log('⚠️ [ProfileCubit] Background refresh FAILED: ${error.getAllErrorMessages()}');
        // Background refresh failed, keep cached data
        if (state is ProfileLoaded) {
          emit((state as ProfileLoaded).copyWith(isRefreshing: false));
        }
      },
      (user) {
        log('🟢 [ProfileCubit] Background refresh SUCCESS');
        emit(ProfileLoaded(user, isFromCache: false, isRefreshing: false));
      },
    );
  }

  /// Force refresh profile (clears cache)
  Future<void> refreshProfile() async {
    log('🔃 [ProfileCubit] Force refresh profile');
    emit(ProfileLoading());
    final result = await userResponseRepo.getUserProfile();
    result.fold(
      (error) {
        log('🔴 [ProfileCubit] Refresh ERROR: ${error.getAllErrorMessages()}');
        emit(ProfileError(error.getAllErrorMessages()));
      },
      (user) {
        log('🟢 [ProfileCubit] Refresh SUCCESS');
        emit(ProfileLoaded(user));
      },
    );
  }
}
