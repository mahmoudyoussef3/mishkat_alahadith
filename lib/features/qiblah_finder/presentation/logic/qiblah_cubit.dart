import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';

part 'qiblah_state.dart';

class QiblahCubit extends Cubit<QiblahState> {
  QiblahCubit() : super(QiblahInitial());

  Future<void> init() async {
    emit(QiblahLoading());

    try {
      final sensorSupported =
          (await FlutterQiblah.androidDeviceSensorSupport()) ?? true;
      if (!sensorSupported) {
        emit(QiblahSensorUnsupported());
        return;
      }

      await _checkLocation();
    } catch (_) {
      emit(const QiblahError('تعذر تهيئة محدد القبلة'));
    }
  }

  Future<void> refresh() => init();

  Future<void> _checkLocation() async {
    final locationStatus = await FlutterQiblah.checkLocationStatus();

    if (!locationStatus.enabled) {
      emit(QiblahLocationDisabled());
      return;
    }

    switch (locationStatus.status) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        emit(QiblahReady());
        return;
      case LocationPermission.denied:
        await FlutterQiblah.requestPermissions();
        final afterRequest = await FlutterQiblah.checkLocationStatus();
        if (!afterRequest.enabled) {
          emit(QiblahLocationDisabled());
          return;
        }
        if (afterRequest.status == LocationPermission.always ||
            afterRequest.status == LocationPermission.whileInUse) {
          emit(QiblahReady());
        } else if (afterRequest.status == LocationPermission.deniedForever) {
          emit(QiblahPermissionDeniedForever());
        } else {
          emit(QiblahPermissionDenied());
        }
        return;
      case LocationPermission.deniedForever:
        emit(QiblahPermissionDeniedForever());
        return;
      case LocationPermission.unableToDetermine:
        emit(QiblahPermissionDenied());
        return;
    }
  }

  @override
  Future<void> close() {
    FlutterQiblah().dispose();
    return super.close();
  }
}
