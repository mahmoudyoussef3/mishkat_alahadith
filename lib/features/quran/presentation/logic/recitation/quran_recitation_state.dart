part of 'quran_recitation_cubit.dart';

@immutable
sealed class QuranRecitationState {
  final RecitationSettings settings;

  const QuranRecitationState(this.settings);

  /// The ayah on the player, if any.
  RecitationTrack? get currentTrack => null;

  /// The ayah being recited, when it is on [page] — so only that page
  /// redraws as the recitation moves on.
  int? recitingAyahOn(int page) {
    final track = currentTrack;
    return track != null && track.page == page ? track.ayahId : null;
  }

  QuranRecitationState withSettings(RecitationSettings settings);
}

final class RecitationIdle extends QuranRecitationState {
  const RecitationIdle(super.settings);

  @override
  RecitationIdle withSettings(RecitationSettings settings) =>
      RecitationIdle(settings);
}

/// The playlist is being fetched.
final class RecitationPreparing extends QuranRecitationState {
  final RecitationRequest request;

  const RecitationPreparing(super.settings, {required this.request});

  @override
  RecitationPreparing withSettings(RecitationSettings settings) =>
      RecitationPreparing(settings, request: request);
}

final class RecitationActive extends QuranRecitationState {
  final RecitationPlaylist playlist;
  final int trackIndex;

  /// [RecitationStatus.loading], [RecitationStatus.playing] or
  /// [RecitationStatus.paused].
  final RecitationStatus status;

  const RecitationActive(
    super.settings, {
    required this.playlist,
    required this.trackIndex,
    required this.status,
  });

  @override
  RecitationTrack get currentTrack => playlist.tracks[trackIndex];

  bool get isPlaying => status == RecitationStatus.playing;

  bool get isLoading => status == RecitationStatus.loading;

  bool get hasPrevious => trackIndex > 0;

  /// Another ayah in the playlist, or a next part to carry on into.
  bool get hasNext =>
      trackIndex < playlist.tracks.length - 1 || playlist.scope.next != null;

  RecitationActive copyWith({int? trackIndex, RecitationStatus? status}) {
    return RecitationActive(
      settings,
      playlist: playlist,
      trackIndex: trackIndex ?? this.trackIndex,
      status: status ?? this.status,
    );
  }

  @override
  RecitationActive withSettings(RecitationSettings settings) =>
      RecitationActive(
        settings,
        playlist: playlist,
        trackIndex: trackIndex,
        status: status,
      );
}

/// The recitation the app was last closed on, offered to pick up again
/// from the ayah it was on. Nothing is on the player until it is.
final class RecitationSuspended extends QuranRecitationState {
  final RecitationResumePoint point;

  const RecitationSuspended(super.settings, {required this.point});

  @override
  RecitationTrack get currentTrack => point.track;

  /// Nothing is recited until it is picked up.
  @override
  int? recitingAyahOn(int page) => null;

  @override
  RecitationSuspended withSettings(RecitationSettings settings) =>
      RecitationSuspended(settings, point: point);
}

final class RecitationFailure extends QuranRecitationState {
  final String message;

  /// What to ask for again to pick up where it failed.
  final RecitationRequest request;

  const RecitationFailure(
    super.settings, {
    required this.message,
    required this.request,
  });

  @override
  RecitationFailure withSettings(RecitationSettings settings) =>
      RecitationFailure(settings, message: message, request: request);
}
