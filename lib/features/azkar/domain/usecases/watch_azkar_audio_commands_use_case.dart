import 'package:mishkat_almasabih/core/domain/entities/media_command.dart';

import '../repos/azkar_audio_repo.dart';

/// The controls used outside the app while a recitation of the azkar plays.
class WatchAzkarAudioCommandsUseCase {
  final AzkarAudioRepo _repo;

  WatchAzkarAudioCommandsUseCase(this._repo);

  Stream<MediaCommand> call() => _repo.commands();
}
