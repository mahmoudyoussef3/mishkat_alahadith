import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/features/profile/domain/entities/user_profile.dart';
import 'package:mishkat_almasabih/features/profile/domain/usecases/get_cached_profile_use_case.dart';
import 'package:mishkat_almasabih/features/profile/domain/usecases/get_profile_use_case.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final GetCachedProfileUseCase _getCachedProfile;
  final GetProfileUseCase _getProfile;
  ProfileCubit(this._getCachedProfile, this._getProfile)
    : super(ProfileInitial());

  Future<void> getUserProfile() async {
    log('👤 [ProfileCubit] Fetching user profile');

    final cached = await _getCachedProfile();

    if (cached != null) {
      log('✅ [ProfileCubit] CACHE HIT - user: ${cached.username ?? "N/A"}');
      emit(ProfileLoaded(cached, isFromCache: true, isRefreshing: true));

      _backgroundRefresh();
    } else {
      log('❌ [ProfileCubit] CACHE MISS - Fetching from API');
      emit(ProfileLoading());
      final result = await _getProfile();
      result.when(
        success: (user) {
          log('🟢 [ProfileCubit] API SUCCESS - user: ${user.username ?? "N/A"}');
          emit(ProfileLoaded(user));
        },
        failure: (failure) {
          log('🔴 [ProfileCubit] API ERROR: ${failure.message}');
          emit(ProfileError(failure.message));
        },
      );
    }
  }

  Future<void> _backgroundRefresh() async {
    log('🔄 [ProfileCubit] Background refresh started');
    final result = await _getProfile();
    result.when(
      success: (user) {
        log('🟢 [ProfileCubit] Background refresh SUCCESS');
        emit(ProfileLoaded(user, isFromCache: false, isRefreshing: false));
      },
      failure: (failure) {
        log('⚠️ [ProfileCubit] Background refresh FAILED: ${failure.message}');
        if (state is ProfileLoaded) {
          emit((state as ProfileLoaded).copyWith(isRefreshing: false));
        }
      },
    );
  }

  /// Shows the profile returned by the edit screen without refetching it.
  void applyUpdatedProfile(UserProfile user) => emit(ProfileLoaded(user));

  Future<void> refreshProfile() async {
    log('🔃 [ProfileCubit] Force refresh profile');
    emit(ProfileLoading());
    final result = await _getProfile();
    result.when(
      success: (user) {
        log('🟢 [ProfileCubit] Refresh SUCCESS');
        emit(ProfileLoaded(user));
      },
      failure: (failure) {
        log('🔴 [ProfileCubit] Refresh ERROR: ${failure.message}');
        emit(ProfileError(failure.message));
      },
    );
  }
}
