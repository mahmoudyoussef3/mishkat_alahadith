import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/recitation.dart';
import '../entities/recitation_settings.dart';
import '../repos/quran_recitation_player_repo.dart';

/// Plays a playlist from one of its tracks, replacing whatever was playing
/// — or only readies it, held, when [paused].
class PlayRecitationUseCase {
  final QuranRecitationPlayerRepo _repo;

  PlayRecitationUseCase(this._repo);

  Future<ApiResult<void>> call(
    RecitationPlaylist playlist, {
    required int startIndex,
    required RecitationSettings settings,
    bool paused = false,
  }) => _repo.play(
    playlist.tracks,
    reciterName: settings.reciterName,
    startIndex: startIndex.clamp(0, playlist.tracks.length - 1),
    repeat: settings.repeat,
    speed: settings.speed,
    paused: paused,
  );
}

class PauseRecitationUseCase {
  final QuranRecitationPlayerRepo _repo;

  PauseRecitationUseCase(this._repo);

  Future<ApiResult<void>> call() => _repo.pause();
}

class ResumeRecitationUseCase {
  final QuranRecitationPlayerRepo _repo;

  ResumeRecitationUseCase(this._repo);

  Future<ApiResult<void>> call() => _repo.resume();
}

/// Silences the player while the next playlist is fetched, keeping its
/// controls outside the app up.
class StandByRecitationUseCase {
  final QuranRecitationPlayerRepo _repo;

  StandByRecitationUseCase(this._repo);

  Future<ApiResult<void>> call() => _repo.standBy();
}

class StopRecitationUseCase {
  final QuranRecitationPlayerRepo _repo;

  StopRecitationUseCase(this._repo);

  Future<ApiResult<void>> call() => _repo.stop();
}

/// Moves to the start of one track of the playlist being played.
class SkipToRecitationTrackUseCase {
  final QuranRecitationPlayerRepo _repo;

  SkipToRecitationTrackUseCase(this._repo);

  Future<ApiResult<void>> call(int index) => _repo.skipTo(index);
}

class SetRecitationSpeedUseCase {
  final QuranRecitationPlayerRepo _repo;

  SetRecitationSpeedUseCase(this._repo);

  Future<ApiResult<void>> call(RecitationSpeed speed) => _repo.setSpeed(speed);
}

class WatchRecitationUseCase {
  final QuranRecitationPlayerRepo _repo;

  WatchRecitationUseCase(this._repo);

  Stream<RecitationPlayback> call() => _repo.watch();

  RecitationProgress? get progress => _repo.progress;
}

class SeekRecitationUseCase {
  final QuranRecitationPlayerRepo _repo;

  SeekRecitationUseCase(this._repo);

  Future<ApiResult<void>> call(String url, Duration position) =>
      _repo.seek(url, position);
}

/// The controls used outside the app: the notification, the lock screen,
/// headphones, a watch or a car.
class WatchRecitationCommandsUseCase {
  final QuranRecitationPlayerRepo _repo;

  WatchRecitationCommandsUseCase(this._repo);

  Stream<RecitationCommand> call() => _repo.commands();
}

/// Each time a recitation of the azkar takes the app's one player from the
/// Quran.
class WatchRecitationTakenOverUseCase {
  final QuranRecitationPlayerRepo _repo;

  WatchRecitationTakenOverUseCase(this._repo);

  Stream<void> call() => _repo.takenOver();
}
