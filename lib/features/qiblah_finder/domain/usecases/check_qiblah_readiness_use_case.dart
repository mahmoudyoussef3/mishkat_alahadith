import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/qiblah_readiness.dart';
import '../repos/qiblah_repo.dart';

class CheckQiblahReadinessUseCase {
  final QiblahRepo _repo;

  CheckQiblahReadinessUseCase(this._repo);

  Future<ApiResult<QiblahReadiness>> call() async {
    switch (await _repo.isSensorSupported()) {
      case ApiFailure(:final failure):
        return ApiResult.failure(failure);
      case ApiSuccess(data: false):
        return const ApiResult.success(QiblahReadiness.sensorUnsupported);
      case ApiSuccess():
        break;
    }

    final QiblahLocationStatus status;
    switch (await _repo.getLocationStatus()) {
      case ApiFailure(:final failure):
        return ApiResult.failure(failure);
      case ApiSuccess(:final data):
        status = data;
    }
    if (!status.enabled) {
      return const ApiResult.success(QiblahReadiness.locationDisabled);
    }

    switch (status.permission) {
      case QiblahPermission.granted:
        return const ApiResult.success(QiblahReadiness.ready);
      case QiblahPermission.deniedForever:
        return const ApiResult.success(QiblahReadiness.permissionDeniedForever);
      case QiblahPermission.undetermined:
        return const ApiResult.success(QiblahReadiness.permissionDenied);
      case QiblahPermission.denied:
        return _askPermission();
    }
  }

  Future<ApiResult<QiblahReadiness>> _askPermission() async {
    if (await _repo.requestPermissions() case ApiFailure(:final failure)) {
      return ApiResult.failure(failure);
    }

    switch (await _repo.getLocationStatus()) {
      case ApiFailure(:final failure):
        return ApiResult.failure(failure);
      case ApiSuccess(:final data) when !data.enabled:
        return const ApiResult.success(QiblahReadiness.locationDisabled);
      case ApiSuccess(:final data):
        return ApiResult.success(switch (data.permission) {
          QiblahPermission.granted => QiblahReadiness.ready,
          QiblahPermission.deniedForever =>
            QiblahReadiness.permissionDeniedForever,
          _ => QiblahReadiness.permissionDenied,
        });
    }
  }
}
