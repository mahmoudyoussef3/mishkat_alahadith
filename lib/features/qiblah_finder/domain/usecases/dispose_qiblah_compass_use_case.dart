import '../repos/qiblah_repo.dart';

class DisposeQiblahCompassUseCase {
  final QiblahRepo _repo;

  DisposeQiblahCompassUseCase(this._repo);

  void call() => _repo.dispose();
}
