import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/remaining_questions.dart';
import '../repos/remaining_questions_repo.dart';

class GetRemainingQuestionsUseCase {
  final RemainingQuestionsRepo _repo;

  GetRemainingQuestionsUseCase(this._repo);

  Future<ApiResult<RemainingQuestions>> call() => _repo.getRemainingQuestions();
}
