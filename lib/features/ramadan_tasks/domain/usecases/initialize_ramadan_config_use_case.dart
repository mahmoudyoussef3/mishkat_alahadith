import '../repos/ramadan_config_repository.dart';

class InitializeRamadanConfigUseCase {
  final RamadanConfigRepository _repo;

  InitializeRamadanConfigUseCase(this._repo);

  Future<void> call() => _repo.initializeRemoteConfig();
}
