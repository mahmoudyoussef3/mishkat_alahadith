part of 'local_hadith_navigation_cubit.dart';

@immutable
sealed class LocalHadithNavigationState {}

final class LocalHadithNavigationInitial extends LocalHadithNavigationState {}
final class LocalHadithNavigationLoading extends LocalHadithNavigationState {}


final class LocalHadithNavigationSuccess extends LocalHadithNavigationState {

  
  final LocalNavigationHadithResponse navigationHadithResponse;
  LocalHadithNavigationSuccess(this.navigationHadithResponse);
}

final class LocalHadithNavigationFailure extends LocalHadithNavigationState {
  final String errMessage;
  LocalHadithNavigationFailure(this.errMessage);
}

