import '../../domain/entities/remaining_questions.dart';
import '../models/remaining_questions_response_model.dart';

extension RemainingQuestionsMapper on RmainingQuestionsResponse {
  RemainingQuestions toEntity() => RemainingQuestions(
    remaining: remaining ?? 0,
    resetTime: resetTime,
    max: max,
    currentCount: currentCount,
  );
}
