import '../entities/speech_event.dart';
import '../repos/read_aloud_repo.dart';

class WatchSpeechEventsUseCase {
  final ReadAloudRepo _repo;

  WatchSpeechEventsUseCase(this._repo);

  Stream<SpeechEvent> call() => _repo.speechEvents;
}
