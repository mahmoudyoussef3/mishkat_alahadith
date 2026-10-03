import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/features/remaining_questions/domain/entities/remaining_questions.dart';
import 'package:mishkat_almasabih/features/remaining_questions/domain/usecases/get_remaining_questions_use_case.dart';

part 'remaining_questions_state.dart';

class RemainingQuestionsCubit extends Cubit<RemainingQuestionsState> {
  final GetRemainingQuestionsUseCase _getRemainingQuestions;
  RemainingQuestionsCubit(this._getRemainingQuestions)
    : super(RemainingQuestionsInitial());

  int remaining = 0;

  Future<void> emitRemainingQuestions() async {
    emit(RemainingQuestionsLoading());
    final result = await _getRemainingQuestions();

    result.when(
      success: (data) {
        remaining = data.remaining;
        emit(RemainingQuestionsSuccess(data));
      },
      failure: (failure) => emit(RemainingQuestionsFailure(failure.message)),
    );
  }
}
