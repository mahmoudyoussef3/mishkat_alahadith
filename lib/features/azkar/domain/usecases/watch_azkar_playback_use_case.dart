import '../entities/azkar_audio.dart';
import '../repos/azkar_audio_repo.dart';

class WatchAzkarPlaybackUseCase {
  final AzkarAudioRepo _repo;

  WatchAzkarPlaybackUseCase(this._repo);

  Stream<AzkarPlaybackStatus> call() => _repo.watchStatus();
}
