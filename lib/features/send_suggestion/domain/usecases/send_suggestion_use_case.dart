import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../repos/suggestion_repo.dart';

class SendSuggestionUseCase {
  final SuggestionRepo _repo;

  SendSuggestionUseCase(this._repo);

  Future<ApiResult<void>> call(String suggestion) =>
      _repo.sendSuggestion(suggestion);
}
