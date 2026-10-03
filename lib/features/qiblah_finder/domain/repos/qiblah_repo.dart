import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/qiblah_readiness.dart';

abstract class QiblahRepo {
  Future<ApiResult<bool>> isSensorSupported();

  Future<ApiResult<QiblahLocationStatus>> getLocationStatus();

  Future<ApiResult<void>> requestPermissions();

  void dispose();
}
