import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/remaining_questions.dart';

abstract class RemainingQuestionsRepo {
  Future<ApiResult<RemainingQuestions>> getRemainingQuestions();
}
