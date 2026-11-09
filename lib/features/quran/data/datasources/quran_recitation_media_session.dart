import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../../domain/entities/recitation.dart';

/// The recitation as the system shows it outside the app — on the
/// notification, the lock screen, a watch or a car — and the controls the
/// listener uses there, headphones' buttons included.
///
/// It shows what the player reports as it comes, except while [hold] keeps
/// it up, loading, between one playlist and the next. The controls are
/// passed to [commands], for the app to act on as on its own buttons.
class QuranRecitationMediaSession extends BaseAudioHandler {
  // The player itself, for a control used while nothing in the app listens
  // to [commands].
  final Future<void> Function() _pausePlayer;
  final Future<void> Function() _stopPlayer;
  final Future<void> Function(Duration position) _seekPlayer;

  /// Those listening to [commands], oldest first.
  final List<StreamController<RecitationCommand>> _listeners = [];

  MediaItem? _item;
  var _holding = false;

  QuranRecitationMediaSession({
    required Future<void> Function() pausePlayer,
    required Future<void> Function() stopPlayer,
    required Future<void> Function(Duration position) seekPlayer,
  }) : _pausePlayer = pausePlayer,
       _stopPlayer = stopPlayer,
       _seekPlayer = seekPlayer;

  /// Each control goes to the newest listener only: the mushaf opened last,
  /// the one on screen, as one opened under it must not act on the
  /// recitation that replaced its own.
  Stream<RecitationCommand> get commands {
    late final StreamController<RecitationCommand> listener;
    listener = StreamController(
      onListen: () => _listeners.add(listener),
      onCancel: () => _listeners.remove(listener),
    );
    return listener.stream;
  }

  /// What the player is doing.
  void showPlayer(PlaybackState state) {
    if (!_holding) playbackState.add(state);
  }

  /// The entry the player is on.
  void showItem(MediaItem item) {
    _item = item;
    if (!_holding) _publishItem();
  }

  /// Keeps what is shown up, as loading, until [release] or [end] — so the
  /// player can be stopped between playlists without the system taking its
  /// controls down. Nothing to keep while nothing is shown.
  void hold() {
    final shown = playbackState.value;
    if (_holding || shown.processingState == AudioProcessingState.idle) return;
    _holding = true;
    playbackState.add(
      shown.copyWith(processingState: AudioProcessingState.loading),
    );
  }

  /// Shows the player again, [state] being what it is doing now and [item]
  /// the entry it is on: the reports still on their way may be from before.
  void release(PlaybackState state, MediaItem? item) {
    if (!_holding) return;
    _holding = false;
    playbackState.add(state);
    if (item != null) _item = item;
    _publishItem();
  }

  /// Takes down whatever is shown.
  void end() {
    final wasShown =
        _holding ||
        playbackState.value.processingState != AudioProcessingState.idle;
    _holding = false;
    if (wasShown) playbackState.add(PlaybackState());
  }

  /// The same ayah repeated is the same entry: shown once, not redrawn.
  void _publishItem() {
    final item = _item;
    final shown = mediaItem.value;
    if (item == null || (shown != null && _sameItem(shown, item))) return;
    mediaItem.add(item);
  }

  static bool _sameItem(MediaItem a, MediaItem b) =>
      a.id == b.id &&
      a.title == b.title &&
      a.artist == b.artist &&
      a.album == b.album &&
      a.duration == b.duration &&
      a.artUri == b.artUri;

  // ── the system's controls ──────────────────────────────────────────────

  @override
  Future<void> play() => _command(RecitationCommand.play);

  @override
  Future<void> pause() => _command(RecitationCommand.pause);

  @override
  Future<void> skipToNext() => _command(RecitationCommand.next);

  @override
  Future<void> skipToPrevious() => _command(RecitationCommand.previous);

  /// Also the notification swiped away, which it is only while paused.
  @override
  Future<void> stop() => _command(RecitationCommand.stop);

  /// Within the ayah: moving to another is [skipToNext] or [skipToPrevious].
  @override
  Future<void> seek(Duration position) => _seekPlayer(position);

  /// The app swiped away from the recent apps: a recitation that is playing
  /// plays on, as in any audio player; a paused one is let go of.
  @override
  Future<void> onTaskRemoved() async {
    if (!playbackState.value.playing) await stop();
  }

  Future<void> _command(RecitationCommand command) async {
    if (_listeners.lastOrNull case final listener?) {
      listener.add(command);
      return;
    }
    // Nothing in the app plays the recitation, which never happens while
    // the mushaf that recites it is open. The player is only silenced then,
    // so one let go of never starts again from a headset or a car.
    final silence = switch (command) {
      RecitationCommand.pause => _pausePlayer,
      RecitationCommand.stop => _stopPlayer,
      RecitationCommand.play ||
      RecitationCommand.next ||
      RecitationCommand.previous => null,
    };
    if (silence == null) return;
    try {
      await silence();
    } catch (error, stackTrace) {
      log(
        'Quran media control ${command.name} failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  // ── what the player reports ────────────────────────────────────────────

  /// [event] as the system shows it, played at [speed].
  static PlaybackState stateOf(PlayerEvent event, {required double speed}) {
    final playback = event.playbackEvent;
    return PlaybackState(
      controls: [_previous, if (event.playing) _pause else _play, _next, _stop],
      // Previous, play or pause, next: all a collapsed notification shows.
      androidCompactActionIndices: const [0, 1, 2],
      systemActions: const {MediaAction.seek},
      processingState: switch (playback.processingState) {
        ProcessingState.idle => AudioProcessingState.idle,
        ProcessingState.loading => AudioProcessingState.loading,
        ProcessingState.buffering => AudioProcessingState.buffering,
        ProcessingState.ready => AudioProcessingState.ready,
        ProcessingState.completed => AudioProcessingState.completed,
      },
      playing: event.playing,
      updatePosition: playback.updatePosition,
      updateTime: playback.updateTime,
      bufferedPosition: playback.bufferedPosition,
      speed: speed,
    );
  }

  // Named as their buttons in the app are, for screen readers.
  static const _previous = MediaControl(
    androidIcon: 'drawable/audio_service_skip_previous',
    label: 'الآية السابقة',
    action: MediaAction.skipToPrevious,
  );
  static const _play = MediaControl(
    androidIcon: 'drawable/audio_service_play_arrow',
    label: 'تشغيل',
    action: MediaAction.play,
  );
  static const _pause = MediaControl(
    androidIcon: 'drawable/audio_service_pause',
    label: 'إيقاف مؤقت',
    action: MediaAction.pause,
  );
  static const _next = MediaControl(
    androidIcon: 'drawable/audio_service_skip_next',
    label: 'الآية التالية',
    action: MediaAction.skipToNext,
  );
  static const _stop = MediaControl(
    androidIcon: 'drawable/audio_service_stop',
    label: 'إيقاف التلاوة',
    action: MediaAction.stop,
  );
}
