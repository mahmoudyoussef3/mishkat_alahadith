part of 'navigation_cubit.dart';

@immutable
sealed class NavigationState {}

final class NavigationInitial extends NavigationState {}

final class NavigationLoading extends NavigationState {}

final class NavigationSuccess extends NavigationState {
  final NavigationHadithResponse navigationHadithResponse;
  final bool isRefreshing;
  final bool isFromCache;

  NavigationSuccess(
    this.navigationHadithResponse, {
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  NavigationSuccess copyWith({
    NavigationHadithResponse? navigationHadithResponse,
    bool? isRefreshing,
    bool? isFromCache,
  }) {
    return NavigationSuccess(
      navigationHadithResponse ?? this.navigationHadithResponse,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

final class NavigationFailure extends NavigationState {
  final String errMessage;
  NavigationFailure(this.errMessage);
}

final class LocalNavigationSuccess extends NavigationState {
  final LocalNavigationHadithResponse navigationHadithResponse;
  LocalNavigationSuccess(this.navigationHadithResponse);
}

final class LocalNavigationFailure extends NavigationState {
  final String errMessage;
  LocalNavigationFailure(this.errMessage);
}
