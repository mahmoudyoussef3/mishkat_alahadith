import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/network_info.dart';

import '../../domain/repos/random_ahadith_repo.dart';
import '../datasources/custom_api_service.dart';
import '../mappers/random_ahadith_mapper.dart';

class RandomAhadithRepoImpl implements RandomAhadithRepo {
  final CustomApiService _customApiService;
  final NetworkInfo _networkInfo;

  RandomAhadithRepoImpl(this._customApiService, this._networkInfo);

  @override
  Future<ApiResult<List<ExplainedHadith>>> getRandomAhadith() async {
    try {
      await _networkInfo.ensureConnected();
      final response = await _customApiService.getRandomAhadith();
      return ApiResult.success(response.toEntities());
    } catch (error) {
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }
}
