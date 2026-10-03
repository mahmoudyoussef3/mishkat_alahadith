part of 'remaining_questions_cubit.dart';

@immutable
sealed class RemainingQuestionsState {}

final class RemainingQuestionsInitial extends RemainingQuestionsState {}

final class RemainingQuestionsLoading extends RemainingQuestionsState {}

final class RemainingQuestionsSuccess extends RemainingQuestionsState {
  final RemainingQuestions remainingQuestions;
  RemainingQuestionsSuccess(this.remainingQuestions);
}

final class RemainingQuestionsFailure extends RemainingQuestionsState {
  final String message;
  RemainingQuestionsFailure(this.message);
}
