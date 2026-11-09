import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/recitation.dart';
import '../entities/recitation_settings.dart';

/// The player the recitations are streamed on. There is one for all of
/// them, so two recitations can never play over each other.
abstract class QuranRecitationPlayerRepo {
  /// Replaces whatever was playing with [tracks] from [startIndex], each
  /// recited as often as [repeat] says, at [speed] — ready but held when
  /// [paused].
  Future<ApiResult<void>> play(
    List<RecitationTrack> tracks, {
    required int startIndex,
    required AyahRepeat repeat,
    required RecitationSpeed speed,
    bool paused = false,
  });

  Future<ApiResult<void>> pause();

  Future<ApiResult<void>> resume();

  Future<ApiResult<void>> stop();

  /// Moves to the start of track [index] of the playlist being played.
  Future<ApiResult<void>> skipTo(int index);

  Future<ApiResult<void>> setSpeed(RecitationSpeed speed);

  /// The player's status, with the track it is on as an index into the
  /// tracks given to [play]. Failures while playing arrive as errors
  /// carrying a `Failure`.
  Stream<RecitationPlayback> watch();
}
