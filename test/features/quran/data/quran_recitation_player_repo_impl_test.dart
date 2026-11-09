import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/data/datasources/quran_recitation_player_datasource.dart';
import 'package:mishkat_almasabih/features/quran/data/repos/quran_recitation_player_repo_impl.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation_settings.dart';

/// The player, recording what it is asked and reporting what the test says;
/// just_audio's own player is never created.
class _FakePlayer extends QuranRecitationPlayerDataSource {
  final StreamController<PlayerState> states = StreamController.broadcast();
  final StreamController<int?> indexes = StreamController.broadcast();
  final StreamController<PlayerException> playerErrors =
      StreamController.broadcast();
  final StreamController<RecitationCommand> controls =
      StreamController.broadcast();

  final List<
    ({
      List<MediaItem> entries,
      List<String> urls,
      int initialIndex,
      bool loopEach,
      double speed,
    })
  >
  queues = [];
  final List<bool> autoplays = [];
  final List<int> seeks = [];
  final List<double> speeds = [];
  int pauses = 0;
  int resumes = 0;
  int standBys = 0;
  int stops = 0;
  Object? playError;

  @override
  Stream<PlayerState> get playerStates => states.stream;

  @override
  Stream<int?> get currentIndexes => indexes.stream;

  @override
  Stream<PlayerException> get errors => playerErrors.stream;

  @override
  Stream<RecitationCommand> get commands => controls.stream;

  @override
  Future<void> playQueue(
    List<MediaItem> entries, {
    required int initialIndex,
    required bool loopEach,
    required double speed,
    bool autoplay = true,
  }) async {
    autoplays.add(autoplay);
    queues.add((
      entries: entries,
      urls: [for (final entry in entries) entry.id],
      initialIndex: initialIndex,
      loopEach: loopEach,
      speed: speed,
    ));
    final error = playError;
    if (error != null) throw error;
  }

  @override
  Future<void> pause() async => pauses++;

  @override
  Future<void> resume() async => resumes++;

  @override
  Future<void> standBy() async => standBys++;

  @override
  Future<void> stop() async => stops++;

  @override
  Future<void> seekToIndex(int index) async => seeks.add(index);

  @override
  Future<void> setSpeed(double speed) async => speeds.add(speed);
}

RecitationTrack _track(int ayahId) => RecitationTrack(
  ayahId: ayahId,
  surahNumber: 112,
  surahName: 'الإخلاص',
  ayahNumber: ayahId - 6221,
  page: 604,
  url: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$ayahId.mp3',
);

final List<RecitationTrack> _tracks = [
  for (var id = 6222; id <= 6225; id++) _track(id),
];

const _reciter = 'مشاري العفاسي';

PlayerState _ready({bool playing = true}) =>
    PlayerState(playing, ProcessingState.ready);

void main() {
  late _FakePlayer player;
  late QuranRecitationPlayerRepoImpl repo;

  setUp(() {
    player = _FakePlayer();
    repo = QuranRecitationPlayerRepoImpl(player);
  });

  /// Lets the stream events sent so far reach their listeners.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  group('play', () {
    test('queues each ayah three times back to back for thrice', () async {
      await repo.play(
        _tracks.take(2).toList(),
        reciterName: _reciter,
        startIndex: 1,
        repeat: AyahRepeat.thrice,
        speed: RecitationSpeed.normal,
      );

      final queue = player.queues.single;
      expect(queue.urls, [
        for (final url in [_tracks[0].url, _tracks[1].url]) ...[url, url, url],
      ]);
      expect(queue.initialIndex, 3);
      expect(queue.loopEach, isFalse);
    });

    test('queues each ayah once and loops it for always', () async {
      await repo.play(
        _tracks,
        reciterName: _reciter,
        startIndex: 2,
        repeat: AyahRepeat.always,
        speed: RecitationSpeed.normal,
      );

      final queue = player.queues.single;
      expect(queue.urls, [for (final t in _tracks) t.url]);
      expect(queue.initialIndex, 2);
      expect(queue.loopEach, isTrue);
    });

    test('names each ayah and its reciter for outside the app', () async {
      await repo.play(
        _tracks.take(2).toList(),
        reciterName: _reciter,
        startIndex: 0,
        repeat: AyahRepeat.once,
        speed: RecitationSpeed.normal,
      );

      final entries = player.queues.single.entries;
      expect(entries.map((e) => e.title), [
        'سورة الإخلاص · الآية ١',
        'سورة الإخلاص · الآية ٢',
      ]);
      expect(entries.map((e) => e.artist), everyElement(_reciter));
    });

    test('plays at the speed asked for', () async {
      await repo.play(
        _tracks,
        reciterName: _reciter,
        startIndex: 0,
        repeat: AyahRepeat.once,
        speed: RecitationSpeed.faster,
      );

      expect(player.queues.single.speed, 1.25);
    });

    test('starts playing unless asked to stay paused', () async {
      await repo.play(
        _tracks,
        reciterName: _reciter,
        startIndex: 0,
        repeat: AyahRepeat.once,
        speed: RecitationSpeed.normal,
      );
      await repo.play(
        _tracks,
        reciterName: _reciter,
        startIndex: 0,
        repeat: AyahRepeat.twice,
        speed: RecitationSpeed.normal,
        paused: true,
      );

      expect(player.autoplays, [true, false]);
    });

    test('fails without touching the player for no tracks', () async {
      final result = await repo.play(
        const [],
        reciterName: _reciter,
        startIndex: 0,
        repeat: AyahRepeat.once,
        speed: RecitationSpeed.normal,
      );

      expect(result, isA<ApiFailure<void>>());
      expect(player.queues, isEmpty);
    });

    test(
      'fails without touching the player for a start out of range',
      () async {
        final result = await repo.play(
          _tracks,
          reciterName: _reciter,
          startIndex: _tracks.length,
          repeat: AyahRepeat.once,
          speed: RecitationSpeed.normal,
        );

        expect(result, isA<ApiFailure<void>>());
        expect(player.queues, isEmpty);
      },
    );

    test('a player that cannot load reports the audio failure', () async {
      player.playError = PlayerException(0, 'Source error', 0);

      final result = await repo.play(
        _tracks,
        reciterName: _reciter,
        startIndex: 0,
        repeat: AyahRepeat.once,
        speed: RecitationSpeed.normal,
      );

      expect(
        (result as ApiFailure<void>).failure,
        isA<UnexpectedFailure>().having(
          (f) => f.message,
          'message',
          FailureMessages.audio,
        ),
      );
    });
  });

  group('skipTo', () {
    test('seeks to the first entry of the track', () async {
      await repo.play(
        _tracks,
        reciterName: _reciter,
        startIndex: 0,
        repeat: AyahRepeat.thrice,
        speed: RecitationSpeed.normal,
      );

      await repo.skipTo(2);

      expect(player.seeks, [6]);
    });

    test('fails for a track that is not queued', () async {
      await repo.play(
        _tracks,
        reciterName: _reciter,
        startIndex: 0,
        repeat: AyahRepeat.once,
        speed: RecitationSpeed.normal,
      );

      final result = await repo.skipTo(_tracks.length);

      expect(result, isA<ApiFailure<void>>());
      expect(player.seeks, isEmpty);
    });

    test('fails before anything is queued', () async {
      expect(await repo.skipTo(0), isA<ApiFailure<void>>());
    });
  });

  group('controls', () {
    test('pause, resume and stop reach the player', () async {
      await repo.pause();
      await repo.resume();
      await repo.stop();

      expect((player.pauses, player.resumes, player.stops), (1, 1, 1));
    });

    test('standing by reaches the player without stopping it', () async {
      await repo.standBy();

      expect((player.standBys, player.stops), (1, 0));
    });

    test('controls used outside the app arrive as they were used', () async {
      final heard = <RecitationCommand>[];
      final subscription = repo.commands().listen(heard.add);
      addTearDown(subscription.cancel);

      player.controls
        ..add(RecitationCommand.next)
        ..add(RecitationCommand.pause);
      await settle();

      expect(heard, [RecitationCommand.next, RecitationCommand.pause]);
    });

    test('speed reaches the player as its factor', () async {
      await repo.setSpeed(RecitationSpeed.slower);

      expect(player.speeds, [0.75]);
    });
  });

  group('watch', () {
    test('maps a queue entry back to the track it plays', () async {
      await repo.play(
        _tracks,
        reciterName: _reciter,
        startIndex: 0,
        repeat: AyahRepeat.thrice,
        speed: RecitationSpeed.normal,
      );
      final heard = <RecitationPlayback>[];
      final subscription = repo.watch().listen(heard.add);
      addTearDown(subscription.cancel);

      player.states.add(_ready());
      player.indexes.add(4);
      await settle();

      expect(
        heard.last,
        const RecitationPlayback(
          status: RecitationStatus.playing,
          trackIndex: 1,
        ),
      );
    });

    test('says nothing before the player has a state', () async {
      final heard = <RecitationPlayback>[];
      final subscription = repo.watch().listen(heard.add);
      addTearDown(subscription.cancel);

      player.indexes.add(0);
      await settle();

      expect(heard, isEmpty);
    });

    test('repeats of the same ayah report it once', () async {
      await repo.play(
        _tracks,
        reciterName: _reciter,
        startIndex: 0,
        repeat: AyahRepeat.thrice,
        speed: RecitationSpeed.normal,
      );
      final heard = <RecitationPlayback>[];
      final subscription = repo.watch().listen(heard.add);
      addTearDown(subscription.cancel);

      player.states.add(_ready());
      player.indexes
        ..add(0)
        ..add(1)
        ..add(2);
      await settle();

      expect(heard.where((p) => p.trackIndex == 0), hasLength(1));
    });

    test('an entry of the old queue is not read as one of the new', () async {
      final twoTracks = _tracks.take(2).toList();
      await repo.play(
        twoTracks,
        reciterName: _reciter,
        startIndex: 0,
        repeat: AyahRepeat.once,
        speed: RecitationSpeed.normal,
      );
      final heard = <RecitationPlayback>[];
      final subscription = repo.watch().listen(heard.add);
      addTearDown(subscription.cancel);
      player.indexes.add(1);
      player.states.add(_ready());
      await settle();
      expect(heard.last.trackIndex, 1);

      await repo.play(
        twoTracks,
        reciterName: _reciter,
        startIndex: 0,
        repeat: AyahRepeat.thrice,
        speed: RecitationSpeed.normal,
      );
      player.states.add(_ready(playing: false));
      await settle();

      // Entry 1 of the new queue is track 0; the player has not said yet
      // where it is in the new queue.
      expect(
        heard.last,
        const RecitationPlayback(status: RecitationStatus.paused),
      );

      player.indexes.add(3);
      await settle();

      expect(heard.last.trackIndex, 1);
    });

    test('a failure while playing arrives as an audio failure', () async {
      final errors = <Object>[];
      final subscription = repo.watch().listen((_) {}, onError: errors.add);
      addTearDown(subscription.cancel);

      player.playerErrors.add(PlayerException(2, 'network', 1));
      await settle();

      expect(
        errors.single,
        isA<UnexpectedFailure>().having(
          (f) => f.message,
          'message',
          FailureMessages.audio,
        ),
      );
    });
  });

  group('statusOf', () {
    RecitationStatus statusOf(bool playing, ProcessingState state) =>
        QuranRecitationPlayerRepoImpl.statusOf(PlayerState(playing, state));

    test('an empty player is idle', () {
      expect(statusOf(false, ProcessingState.idle), RecitationStatus.idle);
    });

    test('loading and buffering are both loading', () {
      expect(statusOf(true, ProcessingState.loading), RecitationStatus.loading);
      expect(
        statusOf(true, ProcessingState.buffering),
        RecitationStatus.loading,
      );
    });

    test('ready and playing is playing', () {
      expect(statusOf(true, ProcessingState.ready), RecitationStatus.playing);
    });

    test('ready but not playing is paused', () {
      expect(statusOf(false, ProcessingState.ready), RecitationStatus.paused);
    });

    test('the end of the queue is completed', () {
      expect(
        statusOf(true, ProcessingState.completed),
        RecitationStatus.completed,
      );
    });
  });
}
