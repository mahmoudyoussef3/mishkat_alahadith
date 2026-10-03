import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../../domain/repos/suggestion_repo.dart';
import '../datasources/suggestion_remote_datasource.dart';

class SuggestionRepoImpl implements SuggestionRepo {
  final SuggestionRemoteDataSource _remote;

  SuggestionRepoImpl(this._remote);

  @override
  Future<ApiResult<void>> sendSuggestion(String suggestion) async {
    final sent = await _remote.sendSuggestion(suggestion);
    return sent
        ? const ApiResult.success(null)
        : const ApiResult.failure(ServerFailure());
  }
}
