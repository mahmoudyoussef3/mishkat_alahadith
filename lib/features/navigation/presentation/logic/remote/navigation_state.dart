part of 'navigation_cubit.dart';

@immutable
sealed class NavigationState {}

final class NavigationInitial extends NavigationState {}

final class NavigationLoading extends NavigationState {}

final class NavigationSuccess extends NavigationState {
  final HadithNavigation navigation;
  final bool isRefreshing;
  final bool isFromCache;

  NavigationSuccess(
    this.navigation, {
    this.isRefreshing = false,
    this.isFromCache = false,
  });

  NavigationSuccess copyWith({
    HadithNavigation? navigation,
    bool? isRefreshing,
    bool? isFromCache,
  }) {
    return NavigationSuccess(
      navigation ?? this.navigation,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

final class NavigationFailure extends NavigationState {
  final String errMessage;
  NavigationFailure(this.errMessage);
}
