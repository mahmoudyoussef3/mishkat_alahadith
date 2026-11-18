import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/recitation.dart';
import '../entities/recitation_settings.dart';

/// The player the recitations are streamed on: the app's one player, shared
/// with the azkar, so two recitations can never play over each other. It
/// plays on with the app in the background, shown with its controls outside
/// the app: on the notification, the lock screen, a watch or a car.
abstract class QuranRecitationPlayerRepo {
  /// Replaces whatever was playing with [tracks] from [startIndex], each
  /// recited as often as [repeat] says, at [speed] — ready but held when
  /// [paused]. Outside the app, each track is shown by its surah and
  /// [reciterName], with one progress bar across the surah.
  Future<ApiResult<void>> play(
    List<RecitationTrack> tracks, {
    required String reciterName,
    required int startIndex,
    required AyahRepeat repeat,
    required RecitationSpeed speed,
    bool paused = false,
  });

  Future<ApiResult<void>> pause();

  Future<ApiResult<void>> resume();

  /// Silences the player while what it plays next is on its way. Unlike
  /// [stop], the controls outside the app stay up, showing it loading: a
  /// recitation that carries on with the app in the background would not
  /// get them back, as Android does not let them return from there.
  Future<ApiResult<void>> standBy();

  /// Silences the player and takes its controls outside the app down.
  Future<ApiResult<void>> stop();

  /// Moves to the start of track [index] of the playlist being played.
  Future<ApiResult<void>> skipTo(int index);

  Future<ApiResult<void>> setSpeed(RecitationSpeed speed);

  /// The player's status, with the track it is on as an index into the
  /// tracks given to [play]. Failures while playing arrive as errors
  /// carrying a `Failure`.
  Stream<RecitationPlayback> watch();

  /// The controls used outside the app, for whoever plays the recitation to
  /// act on as on its own; while no one listens, the player obeys them
  /// itself.
  Stream<RecitationCommand> commands();

  /// Each time something else — a recitation of the azkar — takes the
  /// player: the recitation is gone from it, and calls made since do
  /// nothing until the next [play] or [standBy].
  Stream<void> takenOver();
}
