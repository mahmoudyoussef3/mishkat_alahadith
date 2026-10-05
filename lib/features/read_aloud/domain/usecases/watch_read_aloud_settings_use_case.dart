import '../entities/read_aloud_settings.dart';
import '../repos/read_aloud_repo.dart';

class WatchReadAloudSettingsUseCase {
  final ReadAloudRepo _repo;

  WatchReadAloudSettingsUseCase(this._repo);

  Stream<ReadAloudSettings> call() => _repo.settingsChanges;
}
