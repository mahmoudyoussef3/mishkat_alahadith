import 'package:flutter/foundation.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/network_info.dart';
import 'package:mishkat_almasabih/core/data/datasources/hadeethenc_datasource.dart';

import '../../domain/repos/daily_hadith_repo.dart';
import '../datasources/daily_hadith_local_datasource.dart';
import 'package:mishkat_almasabih/core/data/mappers/explained_hadith_mapper.dart';

class DailyHadithRepoImpl implements DailyHadithRepo {
  final HadeethEncDataSource _remote;
  final DailyHadithLocalDataSource _local;

  final NetworkInfo? _networkInfo;

  DailyHadithRepoImpl(this._remote, this._local, {NetworkInfo? networkInfo})
    : _networkInfo = networkInfo;

  @override
  Future<ExplainedHadith?> getSavedHadith() async {
    try {
      return (await _local.getHadith())?.toEntity();
    } catch (error) {
      debugPrint("❌ Error reading saved hadith: $error");
      return null;
    }
  }

  @override
  Future<ApiResult<ExplainedHadith>> fetchAndSaveHadith(String id) async {
    try {
      await _networkInfo?.ensureConnected();
      final model = await _remote.fetchHadith(id);
      await _local.saveHadith(model);
      debugPrint('✅ New hadith fetched and saved');
      return ApiResult.success(model.toEntity());
    } catch (error) {
      debugPrint("❌ Error fetching hadith: $error");
      return ApiResult.failure(ErrorHandler.toFailure(error));
    }
  }
}
