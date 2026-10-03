import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/qiblah_finder/domain/entities/qiblah_readiness.dart';
import 'package:mishkat_almasabih/features/qiblah_finder/domain/repos/qiblah_repo.dart';
import 'package:mishkat_almasabih/features/qiblah_finder/domain/usecases/check_qiblah_readiness_use_case.dart';

class _FakeQiblahRepo implements QiblahRepo {
  bool sensorSupported = true;
  List<QiblahLocationStatus> statuses = [];
  int permissionRequests = 0;
  bool failStatus = false;

  @override
  Future<ApiResult<bool>> isSensorSupported() async =>
      ApiResult.success(sensorSupported);

  @override
  Future<ApiResult<QiblahLocationStatus>> getLocationStatus() async =>
      failStatus
          ? const ApiResult.failure(UnexpectedFailure())
          : ApiResult.success(statuses.removeAt(0));

  @override
  Future<ApiResult<void>> requestPermissions() async {
    permissionRequests++;
    return const ApiResult.success(null);
  }

  @override
  void dispose() {}
}

QiblahLocationStatus _status(
  QiblahPermission permission, {
  bool enabled = true,
}) => QiblahLocationStatus(enabled: enabled, permission: permission);

void main() {
  late _FakeQiblahRepo repo;
  late CheckQiblahReadinessUseCase check;

  setUp(() {
    repo = _FakeQiblahRepo();
    check = CheckQiblahReadinessUseCase(repo);
  });

  Future<QiblahReadiness> readiness() async =>
      (await check() as ApiSuccess<QiblahReadiness>).data;

  test('reports an unsupported sensor before touching location', () async {
    repo.sensorSupported = false;

    expect(await readiness(), QiblahReadiness.sensorUnsupported);
  });

  test('reports disabled location services', () async {
    repo.statuses = [_status(QiblahPermission.granted, enabled: false)];

    expect(await readiness(), QiblahReadiness.locationDisabled);
  });

  test('is ready when permission is already granted', () async {
    repo.statuses = [_status(QiblahPermission.granted)];

    expect(await readiness(), QiblahReadiness.ready);
    expect(repo.permissionRequests, 0);
  });

  test('asks once when denied and is ready if the user then grants', () async {
    repo.statuses = [
      _status(QiblahPermission.denied),
      _status(QiblahPermission.granted),
    ];

    expect(await readiness(), QiblahReadiness.ready);
    expect(repo.permissionRequests, 1);
  });

  test('reports permanent denial after asking', () async {
    repo.statuses = [
      _status(QiblahPermission.denied),
      _status(QiblahPermission.deniedForever),
    ];

    expect(await readiness(), QiblahReadiness.permissionDeniedForever);
  });

  test('treats an undetermined permission as denied without asking', () async {
    repo.statuses = [_status(QiblahPermission.undetermined)];

    expect(await readiness(), QiblahReadiness.permissionDenied);
    expect(repo.permissionRequests, 0);
  });

  test('propagates a plugin failure instead of throwing', () async {
    repo.failStatus = true;

    final result = await check();

    expect((result as ApiFailure).failure, isA<UnexpectedFailure>());
  });
}
