class UnauthorizedException implements Exception {
  const UnauthorizedException();

  @override
  String toString() => 'UnauthorizedException: no session token';
}

class NoConnectionException implements Exception {
  const NoConnectionException();

  @override
  String toString() => 'NoConnectionException';
}

/// The text-to-speech engine refused or failed a request.
class TextToSpeechException implements Exception {
  final String message;

  const TextToSpeechException(this.message);

  @override
  String toString() => 'TextToSpeechException: $message';
}
