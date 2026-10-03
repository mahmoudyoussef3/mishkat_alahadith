part of 'session_cubit.dart';

sealed class SessionState {
  const SessionState();
}

final class SessionUnknown extends SessionState {
  const SessionUnknown();
}

final class SessionSignedIn extends SessionState {
  const SessionSignedIn();
}

final class SessionSignedOut extends SessionState {
  const SessionSignedOut();
}
