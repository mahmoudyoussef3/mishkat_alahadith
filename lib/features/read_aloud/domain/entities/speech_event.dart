/// Something the speech engine reports about the utterance it is reading.
sealed class SpeechEvent {
  const SpeechEvent();
}

final class SpeechStarted extends SpeechEvent {
  const SpeechStarted();
}

final class SpeechCompleted extends SpeechEvent {
  const SpeechCompleted();
}

final class SpeechPaused extends SpeechEvent {
  const SpeechPaused();
}

/// A paused utterance carries on.
final class SpeechResumed extends SpeechEvent {
  const SpeechResumed();
}

final class SpeechCancelled extends SpeechEvent {
  const SpeechCancelled();
}

/// The engine is about to say `text[start, end)`.
///
/// [text] is the utterance as the engine holds it, which after an Android
/// pause is only the part that was still left to say.
final class SpeechProgress extends SpeechEvent {
  final String text;
  final int start;
  final int end;

  const SpeechProgress({
    required this.text,
    required this.start,
    required this.end,
  });
}

final class SpeechFailed extends SpeechEvent {
  final String message;

  const SpeechFailed(this.message);
}
