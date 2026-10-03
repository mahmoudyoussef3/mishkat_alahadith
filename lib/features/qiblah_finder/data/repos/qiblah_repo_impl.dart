import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mishkat_almasabih/core/networking/api_error_handler.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../../domain/entities/qiblah_readiness.dart';
import '../../domain/repos/qiblah_repo.dart';

class QiblahRepoImpl implements QiblahRepo {
  @override
  Future<ApiResult<bool>> isSensorSupported() => guardApiCall(
    () async => (await FlutterQiblah.androidDeviceSensorSupport()) ?? true,
  );

  @override
  Future<ApiResult<QiblahLocationStatus>> getLocationStatus() => guardApiCall(
    () async {
      final status = await FlutterQiblah.checkLocationStatus();
      return QiblahLocationStatus(
        enabled: status.enabled,
        permission: switch (status.status) {
          LocationPermission.always ||
          LocationPermission.whileInUse => QiblahPermission.granted,
          LocationPermission.denied => QiblahPermission.denied,
          LocationPermission.deniedForever => QiblahPermission.deniedForever,
          LocationPermission.unableToDetermine => QiblahPermission.undetermined,
        },
      );
    },
  );

  @override
  Future<ApiResult<void>> requestPermissions() =>
      guardApiCall(FlutterQiblah.requestPermissions);

  @override
  void dispose() => FlutterQiblah().dispose();
}
