part of 'random_ahadith_cubit.dart';

@immutable
sealed class RandomAhadithState {}

final class RandomAhadithInitial extends RandomAhadithState {}

final class RandomAhadithLoading extends RandomAhadithState {}

final class RandomAhadithSuccess extends RandomAhadithState {
  final RandomAhadithResponse randomAhadithResponse;
  RandomAhadithSuccess(this.randomAhadithResponse);
}

final class RandomAhaditFailure extends RandomAhadithState {
  final String errMessage;
  RandomAhaditFailure(this.errMessage);
}
