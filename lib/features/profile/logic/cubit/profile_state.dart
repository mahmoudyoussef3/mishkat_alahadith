part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

final class ProfileLoading extends ProfileState {}

final class ProfileLoaded extends ProfileState {
  final UserResponseModel user;
  final bool isRefreshing;
  final bool isFromCache;

  ProfileLoaded(
    this.user, {
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  ProfileLoaded copyWith({
    UserResponseModel? user,
    bool? isRefreshing,
    bool? isFromCache,
  }) {
    return ProfileLoaded(
      user ?? this.user,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

final class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
