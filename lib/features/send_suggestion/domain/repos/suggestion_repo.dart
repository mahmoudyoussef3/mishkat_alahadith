import 'package:mishkat_almasabih/core/networking/api_result.dart';

abstract class SuggestionRepo {
  Future<ApiResult<void>> sendSuggestion(String suggestion);
}
