import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mishkat_almasabih/core/audio/app_media_session.dart';
import 'package:mishkat_almasabih/core/domain/entities/media_command.dart';

PlaybackState _state({
  bool playing = true,
  ProcessingState processing = ProcessingState.ready,
  double speed = 1.0,
  Duration position = Duration.zero,
  Duration offset = Duration.zero,
  bool skippable = true,
}) => AppMediaSession.stateOf(
  PlayerEvent(
    playing: playing,
    playbackEvent: PlaybackEvent(
      processingState: processing,
      updatePosition: position,
      bufferedPosition: position,
    ),
  ),
  speed: speed,
  offset: offset,
  skippable: skippable,
);

MediaItem _item(int ayah, {Duration? duration}) => MediaItem(
  id: 'https://cdn.example/$ayah.mp3',
  title: 'سورة الإخلاص · الآية $ayah',
  artist: 'مشاري العفاسي',
  duration: duration,
);

void main() {
  /// What the player itself was told to do.
  late List<MediaCommand> obeyed;
  late List<Duration> seeks;
  late AppMediaSession session;

  /// Who the player plays for in these tests, and someone else.
  final quran = Object();
  final azkar = Object();

  setUp(() {
    obeyed = [];
    seeks = [];
    session = AppMediaSession(
      pausePlayer: () async => obeyed.add(MediaCommand.pause),
      stopPlayer: () async => obeyed.add(MediaCommand.stop),
      seekPlayer: (position) async => seeks.add(position),
    )..holder = quran;
  });

  /// Lets the stream events sent so far reach their listeners.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('stateOf', () {
    test('offers pause while playing and play while not', () {
      expect(_state().controls.map((c) => c.action), [
        MediaAction.skipToPrevious,
        MediaAction.pause,
        MediaAction.skipToNext,
        MediaAction.stop,
      ]);
      expect(
        _state(playing: false).controls.map((c) => c.action),
        contains(MediaAction.play),
      );
    });

    test('keeps previous, play or pause and next when collapsed', () {
      expect(_state().androidCompactActionIndices, [0, 1, 2]);
    });

    test('offers only play or pause and stop with nothing to skip to', () {
      final state = _state(skippable: false);

      expect(state.controls.map((c) => c.action), [
        MediaAction.pause,
        MediaAction.stop,
      ]);
      expect(state.androidCompactActionIndices, [0, 1]);
    });

    test('lets the surah be seeked through', () {
      expect(_state().systemActions, {MediaAction.seek});
    });

    test('carries the processing state across', () {
      expect(
        _state(processing: ProcessingState.buffering).processingState,
        AudioProcessingState.buffering,
      );
      expect(
        _state(processing: ProcessingState.completed).processingState,
        AudioProcessingState.completed,
      );
    });

    test('carries the speed, so the progress moves at it', () {
      expect(_state(speed: 1.25).speed, 1.25);
    });

    test('places the ayah where it starts on the bar of its surah', () {
      final state = _state(
        position: const Duration(seconds: 3),
        offset: const Duration(seconds: 40),
      );

      expect(state.updatePosition, const Duration(seconds: 43));
      expect(state.bufferedPosition, const Duration(seconds: 43));
    });
  });

  group('showing', () {
    test('shows what the player reports', () {
      session.showPlayer(_state());

      expect(session.playbackState.value.playing, isTrue);
      expect(
        session.playbackState.value.processingState,
        AudioProcessingState.ready,
      );
    });

    test('shows the entry the player is on', () {
      session.showItem(_item(1));

      expect(session.mediaItem.value?.title, 'سورة الإخلاص · الآية 1');
    });

    test(
      'shows a repeated ayah once, and again once its length is known',
      () async {
        final shown = <MediaItem?>[];
        final subscription = session.mediaItem.listen(shown.add);
        addTearDown(subscription.cancel);

        session
          ..showItem(_item(1))
          ..showItem(_item(1))
          ..showItem(_item(1, duration: const Duration(seconds: 4)));
        await settle();

        // Nothing yet, then the ayah, then its length.
        expect(shown, hasLength(3));
        expect(shown.last?.duration, const Duration(seconds: 4));
      },
    );
  });

  group('holding', () {
    test('keeps what is shown up, loading and still playing', () {
      session
        ..showItem(_item(7))
        ..showPlayer(_state())
        ..hold();

      final shown = session.playbackState.value;
      expect(shown.processingState, AudioProcessingState.loading);
      expect(shown.playing, isTrue);
      expect(session.mediaItem.value?.id, _item(7).id);
    });

    test('ignores the player stopping and loading meanwhile', () {
      session
        ..showItem(_item(7))
        ..showPlayer(_state())
        ..hold()
        ..showPlayer(_state(playing: false, processing: ProcessingState.idle))
        ..showItem(_item(1));

      expect(session.playbackState.value.playing, isTrue);
      expect(
        session.playbackState.value.processingState,
        AudioProcessingState.loading,
      );
      expect(session.mediaItem.value?.id, _item(7).id);
    });

    test('released, shows the player as it is now', () {
      session
        ..showItem(_item(7))
        ..showPlayer(_state())
        ..hold()
        ..release(_state(processing: ProcessingState.buffering), _item(1));

      expect(
        session.playbackState.value.processingState,
        AudioProcessingState.buffering,
      );
      expect(session.mediaItem.value?.id, _item(1).id);
    });

    test('holds nothing while nothing is shown', () {
      session.hold();

      expect(
        session.playbackState.value.processingState,
        AudioProcessingState.idle,
      );
    });

    test('released while not holding, changes nothing', () {
      session
        ..showPlayer(_state())
        ..release(_state(playing: false), null);

      expect(session.playbackState.value.playing, isTrue);
    });
  });

  group('ending', () {
    test('takes down what is shown, even while holding', () {
      session
        ..showPlayer(_state())
        ..hold()
        ..end();

      expect(
        session.playbackState.value.processingState,
        AudioProcessingState.idle,
      );
      expect(session.playbackState.value.playing, isFalse);
    });

    test('shows the player again once a new queue plays', () {
      session
        ..showPlayer(_state())
        ..hold()
        ..end()
        ..showPlayer(_state());

      expect(session.playbackState.value.playing, isTrue);
    });
  });

  group('controls', () {
    final controls =
        <(String, Future<void> Function(AppMediaSession), MediaCommand)>[
          ('play', (s) => s.play(), MediaCommand.play),
          ('pause', (s) => s.pause(), MediaCommand.pause),
          ('next', (s) => s.skipToNext(), MediaCommand.next),
          ('previous', (s) => s.skipToPrevious(), MediaCommand.previous),
          ('stop', (s) => s.stop(), MediaCommand.stop),
        ];

    for (final (name, use, command) in controls) {
      test('$name goes to whoever listens, not the player', () async {
        final heard = <MediaCommand>[];
        final subscription = session.commandsOf(quran).listen(heard.add);
        addTearDown(subscription.cancel);

        await use(session);
        await settle();

        expect(heard, [command]);
        expect(obeyed, isEmpty);
      });
    }

    test(
      'only the newest listener hears them, the older once it is gone',
      () async {
        final older = <MediaCommand>[];
        final newer = <MediaCommand>[];
        final olderSubscription = session.commandsOf(quran).listen(older.add);
        addTearDown(olderSubscription.cancel);
        final newerSubscription = session.commandsOf(quran).listen(newer.add);

        await session.skipToNext();
        await settle();
        expect(older, isEmpty);
        expect(newer, [MediaCommand.next]);

        await newerSubscription.cancel();
        await session.skipToNext();
        await settle();
        expect(older, [MediaCommand.next]);
      },
    );

    test('go to whoever the player plays for, not another', () async {
      final forQuran = <MediaCommand>[];
      final forAzkar = <MediaCommand>[];
      final quranSubscription = session.commandsOf(quran).listen(forQuran.add);
      addTearDown(quranSubscription.cancel);
      final azkarSubscription = session.commandsOf(azkar).listen(forAzkar.add);
      addTearDown(azkarSubscription.cancel);

      await session.pause();
      session.holder = azkar;
      await session.play();
      await settle();

      expect(forQuran, [MediaCommand.pause]);
      expect(forAzkar, [MediaCommand.play]);
    });

    test(
      'while the one played for does not listen, the player obeys itself',
      () async {
        final other = <MediaCommand>[];
        final subscription = session.commandsOf(azkar).listen(other.add);
        addTearDown(subscription.cancel);

        await session.pause();
        await settle();

        expect(other, isEmpty);
        expect(obeyed, [MediaCommand.pause]);
      },
    );

    test('with no one listening, the player pauses and stops itself', () async {
      await session.pause();
      await session.stop();

      expect(obeyed, [MediaCommand.pause, MediaCommand.stop]);
    });

    test('with no one listening, nothing starts the player again', () async {
      await session.play();
      await session.skipToNext();
      await session.skipToPrevious();

      expect(obeyed, isEmpty);
    });

    test('the notification swiped away stops the recitation', () async {
      await session.onNotificationDeleted();

      expect(obeyed, [MediaCommand.stop]);
    });

    test('a click on headphones pauses what plays', () async {
      session.showPlayer(_state());

      await session.click();

      expect(obeyed, [MediaCommand.pause]);
    });

    test('seeking reaches the player', () async {
      await session.seek(const Duration(seconds: 3));

      expect(seeks, [const Duration(seconds: 3)]);
    });

    test('a failing player does not throw back at the system', () async {
      final failing = AppMediaSession(
        pausePlayer: () async => throw StateError('no player'),
        stopPlayer: () async => throw StateError('no player'),
        seekPlayer: (_) async {},
      );

      await expectLater(failing.pause(), completes);
    });
  });

  group('the app swiped away', () {
    test('a recitation playing plays on', () async {
      session.showPlayer(_state());

      await session.onTaskRemoved();

      expect(obeyed, isEmpty);
    });

    test('a paused one is let go of', () async {
      session.showPlayer(_state(playing: false));

      await session.onTaskRemoved();

      expect(obeyed, [MediaCommand.stop]);
    });
  });
}
