import 'dart:async';
import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mishkat_almasabih/core/domain/entities/media_command.dart';

/// What the app's one player plays — a recitation of the Quran or of the
/// azkar — as the system shows it outside the app: on the notification, the
/// lock screen, a watch or a car; and the controls the listener uses there,
/// headphones' buttons included.
///
/// It shows what the player reports as it comes, except while [hold] keeps
/// it up, loading, between one playlist and the next. The controls are
/// passed to [commandsOf] the [holder], for it to act on as on its own
/// buttons.
class AppMediaSession extends BaseAudioHandler {
  // The player itself, for a control used while its holder does not
  // listen to [commandsOf].
  final Future<void> Function() _pausePlayer;
  final Future<void> Function() _stopPlayer;
  final Future<void> Function(Duration position) _seekPlayer;

  /// Those listening to [commandsOf], by whom they listen for, oldest
  /// first.
  final Map<Object, List<StreamController<MediaCommand>>> _listeners = {};

  /// Who the player plays for now; the controls are theirs.
  Object? holder;

  MediaItem? _item;
  var _holding = false;

  AppMediaSession({
    required Future<void> Function() pausePlayer,
    required Future<void> Function() stopPlayer,
    required Future<void> Function(Duration position) seekPlayer,
  }) : _pausePlayer = pausePlayer,
       _stopPlayer = stopPlayer,
       _seekPlayer = seekPlayer;

  /// The controls used while the player plays for [owner]. Each goes to the
  /// newest of its listeners only, as one that came before must not act on
  /// the recitation that replaced its own.
  Stream<MediaCommand> commandsOf(Object owner) {
    late final StreamController<MediaCommand> listener;
    listener = StreamController(
      onListen: () => _listeners.putIfAbsent(owner, () => []).add(listener),
      onCancel: () {
        final listeners = _listeners[owner];
        listeners?.remove(listener);
        if (listeners != null && listeners.isEmpty) _listeners.remove(owner);
      },
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
  Future<void> play() => _command(MediaCommand.play);

  @override
  Future<void> pause() => _command(MediaCommand.pause);

  @override
  Future<void> skipToNext() => _command(MediaCommand.next);

  @override
  Future<void> skipToPrevious() => _command(MediaCommand.previous);

  /// Also the notification swiped away, which it is only while paused.
  @override
  Future<void> stop() => _command(MediaCommand.stop);

  /// Anywhere on the bar of the part shown, into whichever entry it is at.
  @override
  Future<void> seek(Duration position) => _seekPlayer(position);

  /// The app swiped away from the recent apps: a recitation that is playing
  /// plays on, as in any audio player; a paused one is let go of.
  @override
  Future<void> onTaskRemoved() async {
    if (!playbackState.value.playing) await stop();
  }

  Future<void> _command(MediaCommand command) async {
    if (_listeners[holder]?.lastOrNull case final listener?) {
      listener.add(command);
      return;
    }
    // No one in the app plays for the holder, which never happens while the
    // app is running. The player is only silenced then, so one let go of
    // never starts again from a headset or a car.
    final silence = switch (command) {
      MediaCommand.pause => _pausePlayer,
      MediaCommand.stop => _stopPlayer,
      MediaCommand.play || MediaCommand.next || MediaCommand.previous => null,
    };
    if (silence == null) return;
    try {
      await silence();
    } catch (error, stackTrace) {
      log(
        'Media control ${command.name} failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  // ── what the player reports ────────────────────────────────────────────

  /// [event] as the system shows it, played at [speed]: the entry played
  /// starting at [offset] on the progress bar, which spans its part. Only a
  /// [skippable] recitation — one with an entry before or after, as the
  /// ayahs of a surah are — offers previous and next.
  static PlaybackState stateOf(
    PlayerEvent event, {
    required double speed,
    Duration offset = Duration.zero,
    bool skippable = true,
  }) {
    final playback = event.playbackEvent;
    final playOrPause = event.playing ? _pause : _play;
    return PlaybackState(
      controls:
          skippable
              ? [_previous, playOrPause, _next, _stop]
              : [playOrPause, _stop],
      // Previous, play or pause, next: all a collapsed notification shows.
      androidCompactActionIndices: skippable ? const [0, 1, 2] : const [0, 1],
      systemActions: const {MediaAction.seek},
      processingState: switch (playback.processingState) {
        ProcessingState.idle => AudioProcessingState.idle,
        ProcessingState.loading => AudioProcessingState.loading,
        ProcessingState.buffering => AudioProcessingState.buffering,
        ProcessingState.ready => AudioProcessingState.ready,
        ProcessingState.completed => AudioProcessingState.completed,
      },
      playing: event.playing,
      updatePosition: offset + playback.updatePosition,
      updateTime: playback.updateTime,
      bufferedPosition: offset + playback.bufferedPosition,
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
