part of 'azkar_audio_cubit.dart';

@immutable
sealed class AzkarAudioState {
  const AzkarAudioState();

  /// The recitation on the player, if any.
  AzkarAudioTrack? get track => null;
}

final class AzkarAudioIdle extends AzkarAudioState {
  const AzkarAudioIdle();
}

final class AzkarAudioActive extends AzkarAudioState {
  @override
  final AzkarAudioTrack track;

  /// [AzkarPlaybackStatus.loading], [AzkarPlaybackStatus.playing] or
  /// [AzkarPlaybackStatus.paused].
  final AzkarPlaybackStatus status;

  const AzkarAudioActive({required this.track, required this.status});

  bool get isLoading => status == AzkarPlaybackStatus.loading;

  bool get isPlaying => status == AzkarPlaybackStatus.playing;
}

/// The recitation the app was last closed on, offered to play again.
/// Nothing is on the player until it does.
final class AzkarAudioSuspended extends AzkarAudioState {
  @override
  final AzkarAudioTrack track;

  const AzkarAudioSuspended({required this.track});
}

final class AzkarAudioFailure extends AzkarAudioState {
  @override
  final AzkarAudioTrack track;
  final String message;

  const AzkarAudioFailure({required this.track, required this.message});
}
