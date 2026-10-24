part of 'random_ahadith_cubit.dart';

@immutable
sealed class RandomAhadithState {}

final class RandomAhadithInitial extends RandomAhadithState {}

final class RandomAhadithLoading extends RandomAhadithState {}

final class RandomAhadithSuccess extends RandomAhadithState {
  final List<ExplainedHadith> hadiths;

  /// True while a new selection loads; [hadiths] stay on screen meanwhile.
  final bool refreshing;

  /// Why the last refresh failed, when it did. [hadiths] are then the ones
  /// that were already on screen.
  final String? refreshFailure;

  RandomAhadithSuccess(
    this.hadiths, {
    this.refreshing = false,
    this.refreshFailure,
  });
}

final class RandomAhaditFailure extends RandomAhadithState {
  final String errMessage;
  RandomAhaditFailure(this.errMessage);
}
