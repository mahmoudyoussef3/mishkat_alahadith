import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:mishkat_almasabih/features/qiblah_finder/domain/entities/qiblah_readiness.dart';
import 'package:mishkat_almasabih/features/qiblah_finder/domain/usecases/check_qiblah_readiness_use_case.dart';
import 'package:mishkat_almasabih/features/qiblah_finder/domain/usecases/dispose_qiblah_compass_use_case.dart';

part 'qiblah_state.dart';

class QiblahCubit extends Cubit<QiblahState> {
  final CheckQiblahReadinessUseCase _checkReadiness;
  final DisposeQiblahCompassUseCase _disposeCompass;

  QiblahCubit(this._checkReadiness, this._disposeCompass)
    : super(QiblahInitial());

  Future<void> init() async {
    emit(QiblahLoading());

    final result = await _checkReadiness();
    result.when(
      success:
          (readiness) => emit(switch (readiness) {
            QiblahReadiness.ready => QiblahReady(),
            QiblahReadiness.sensorUnsupported => QiblahSensorUnsupported(),
            QiblahReadiness.locationDisabled => QiblahLocationDisabled(),
            QiblahReadiness.permissionDenied => QiblahPermissionDenied(),
            QiblahReadiness.permissionDeniedForever =>
              QiblahPermissionDeniedForever(),
          }),
      failure: (_) => emit(const QiblahError('تعذر تهيئة محدد القبلة')),
    );
  }

  Future<void> refresh() => init();

  @override
  Future<void> close() {
    _disposeCompass();
    return super.close();
  }
}
