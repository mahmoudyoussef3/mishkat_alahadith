import '../repos/azkar_audio_repo.dart';

/// Each time a recitation of the Quran takes the app's one player from the
/// azkar.
class WatchAzkarAudioTakenOverUseCase {
  final AzkarAudioRepo _repo;

  WatchAzkarAudioTakenOverUseCase(this._repo);

  Stream<void> call() => _repo.takenOver();
}
