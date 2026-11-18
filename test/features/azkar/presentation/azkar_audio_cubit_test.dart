import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/domain/entities/media_command.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_audio.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_audio/azkar_audio_cubit.dart';

import '../azkar_fakes.dart';

const _first = AzkarAudioTrack(audioFile: '75.mp3', categoryId: 27, zikrId: 1);
const _second = AzkarAudioTrack(audioFile: '76.mp3', categoryId: 27, zikrId: 2);

void main() {
  late FakeAzkarAudioRepo player;
  late AzkarAudioCubit cubit;

  setUp(() {
    player = FakeAzkarAudioRepo();
    cubit = audioCubitFor(player);
  });

  tearDown(() => cubit.close());

  /// Pushes [status] from the player and lets the cubit hear it.
  Future<void> report(AzkarPlaybackStatus status) async {
    player.statuses.add(status);
    await pumpEventQueue();
  }

  test('plays a recitation once it is on the device', () async {
    await cubit.play(_first);

    expect(player.played, ['/cache/75.mp3']);
    expect((cubit.state as AzkarAudioActive).isLoading, isTrue);
  });

  test('shows playing once the player starts', () async {
    await cubit.play(_first);

    await report(AzkarPlaybackStatus.playing);

    expect((cubit.state as AzkarAudioActive).isPlaying, isTrue);
  });

  test('hides the passing states while getting ready to play', () async {
    player.holdDownloads = true;
    final playing = cubit.play(_first);
    await pumpEventQueue();

    await report(AzkarPlaybackStatus.paused);

    expect((cubit.state as AzkarAudioActive).isLoading, isTrue);
    player.finishDownload('75.mp3');
    await playing;
  });

  test('a recitation that never gets going shows as paused', () async {
    player.holdDownloads = true;
    final playing = cubit.play(_first);
    await pumpEventQueue();
    await report(AzkarPlaybackStatus.paused);

    player.finishDownload('75.mp3');
    await playing;

    final state = cubit.state as AzkarAudioActive;
    expect(state.status, AzkarPlaybackStatus.paused);
  });

  test('a pause from the player after it started is shown', () async {
    await cubit.play(_first);

    await report(AzkarPlaybackStatus.paused);

    final state = cubit.state as AzkarAudioActive;
    expect(state.status, AzkarPlaybackStatus.paused);
  });

  test(
    'a download that finishes after a newer request is not played',
    () async {
      player.holdDownloads = true;
      final older = cubit.play(_first);
      final newer = cubit.play(_second);
      await pumpEventQueue();
      player.finishDownload('76.mp3');
      await newer;
      player.finishDownload('75.mp3');
      await older;

      expect(player.played, ['/cache/76.mp3']);
      expect(cubit.state.track, _second);
    },
  );

  test('a failed download is shown, then set aside', () async {
    player.downloadFailure = const ServerFailure(
      FailureMessages.audioUnavailable,
      404,
    );

    await cubit.play(_first);

    final failure = cubit.state as AzkarAudioFailure;
    expect(failure.message, FailureMessages.audioUnavailable);
    cubit.dismissFailure();
    expect(cubit.state, isA<AzkarAudioIdle>());
  });

  test('toggle pauses the playing track and resumes it', () async {
    await cubit.play(_first);
    await report(AzkarPlaybackStatus.playing);

    await cubit.toggle(_first);
    expect(
      (cubit.state as AzkarAudioActive).status,
      AzkarPlaybackStatus.paused,
    );

    await cubit.toggle(_first);
    expect((cubit.state as AzkarAudioActive).isPlaying, isTrue);
    expect((player.pauses, player.resumes), (1, 1));
  });

  test('toggle on another track plays that one instead', () async {
    await cubit.play(_first);
    await report(AzkarPlaybackStatus.playing);

    await cubit.toggle(_second);

    expect(player.played.last, '/cache/76.mp3');
  });

  test('goes back to rest when the recitation ends', () async {
    await cubit.play(_first);
    await report(AzkarPlaybackStatus.playing);

    await report(AzkarPlaybackStatus.completed);

    expect(cubit.state, isA<AzkarAudioIdle>());
  });

  test('a player error is shown', () async {
    await cubit.play(_first);
    await report(AzkarPlaybackStatus.playing);

    player.statuses.addError(const UnexpectedFailure(FailureMessages.audio));
    await pumpEventQueue();

    expect((cubit.state as AzkarAudioFailure).message, FailureMessages.audio);
  });

  test('closing the cubit stops the player', () async {
    await cubit.play(_first);
    final stopsBefore = player.stops;

    await cubit.close();

    expect(player.stops, stopsBefore + 1);
  });

  group('on the app\'s one player', () {
    test('takes it at once, before the recitation downloads', () async {
      player.holdDownloads = true;
      final playing = cubit.play(_first);
      await pumpEventQueue();

      expect(player.standBys, 1);
      expect(player.stops, 0);
      player.finishDownload('75.mp3');
      await playing;
    });

    test('names the recitation it plays', () async {
      await cubit.play(_first);

      expect(player.playedTracks, [_first]);
    });

    test('a failed download takes the controls kept up down', () async {
      player.downloadFailure = const NetworkFailure();

      await cubit.play(_first);

      expect(cubit.state, isA<AzkarAudioFailure>());
      expect(player.stops, 1);
    });

    test('the Quran taking it ends the recitation, leaving it be', () async {
      await cubit.play(_first);
      await report(AzkarPlaybackStatus.playing);
      final stopsBefore = player.stops;

      player.takeovers.add(null);
      await pumpEventQueue();

      expect(cubit.state, isA<AzkarAudioIdle>());
      expect(player.stops, stopsBefore);
    });

    test(
      'what the Quran played, heard while downloading, is not shown',
      () async {
        player.holdDownloads = true;
        final playing = cubit.play(_first);
        await pumpEventQueue();

        await report(AzkarPlaybackStatus.playing);
        player.statuses.addError(
          const UnexpectedFailure(FailureMessages.audio),
        );
        await pumpEventQueue();

        final state = cubit.state as AzkarAudioActive;
        expect(state.isLoading, isTrue);
        player.finishDownload('75.mp3');
        await playing;
      },
    );

    test('a download finishing after the Quran took it never plays', () async {
      player.holdDownloads = true;
      final playing = cubit.play(_first);
      await pumpEventQueue();

      player.takeovers.add(null);
      await pumpEventQueue();
      player.finishDownload('75.mp3');
      await playing;

      expect(player.played, isEmpty);
      expect(cubit.state, isA<AzkarAudioIdle>());
    });
  });

  group('controls outside the app', () {
    Future<void> use(MediaCommand command) async {
      player.controls.add(command);
      await pumpEventQueue();
    }

    test('pause and play pause and resume the recitation', () async {
      await cubit.play(_first);
      await report(AzkarPlaybackStatus.playing);

      await use(MediaCommand.pause);
      expect(
        (cubit.state as AzkarAudioActive).status,
        AzkarPlaybackStatus.paused,
      );

      await use(MediaCommand.play);
      expect(player.resumes, 1);
    });

    test('stop ends the recitation', () async {
      await cubit.play(_first);
      await report(AzkarPlaybackStatus.playing);

      await use(MediaCommand.stop);

      expect(cubit.state, isA<AzkarAudioIdle>());
    });

    test('next and previous have nothing to skip to', () async {
      await cubit.play(_first);
      await report(AzkarPlaybackStatus.playing);

      await use(MediaCommand.next);
      await use(MediaCommand.previous);

      expect(player.played, hasLength(1));
      expect((cubit.state as AzkarAudioActive).isPlaying, isTrue);
    });
  });

  group('picking up after the app was closed', () {
    test('keeps the recitation on the player', () async {
      await cubit.play(_first);

      expect(player.lastTrack, _first);
    });

    test('writes it once, whatever its status', () async {
      await cubit.play(_first);
      await report(AzkarPlaybackStatus.playing);
      await report(AzkarPlaybackStatus.paused);

      expect(player.savedTracks, [_first]);
    });

    test('forgets it once it ends', () async {
      await cubit.play(_first);
      await report(AzkarPlaybackStatus.playing);

      await report(AzkarPlaybackStatus.completed);

      expect(player.lastTrack, isNull);
    });

    test('forgets it once stopped', () async {
      await cubit.play(_first);

      await cubit.stop();

      expect(player.lastTrack, isNull);
    });

    test('offers the one left playing, held', () async {
      player.lastTrack = _second;

      await cubit.restore();

      expect((cubit.state as AzkarAudioSuspended).track, _second);
      expect(player.played, isEmpty);
      expect(player.standBys, 0);
    });

    test('offers nothing once something else was asked for', () async {
      player.lastTrack = _second;
      await cubit.play(_first);

      await cubit.restore();

      expect(cubit.state.track, _first);
    });

    test('playing it plays it from the start', () async {
      player.lastTrack = _second;
      await cubit.restore();

      await cubit.toggle(_second);

      expect(player.played, ['/cache/76.mp3']);
    });

    test('the Quran taking the player drops it', () async {
      player.lastTrack = _second;
      await cubit.restore();

      player.takeovers.add(null);
      await pumpEventQueue();

      expect(cubit.state, isA<AzkarAudioIdle>());
      expect(player.lastTrack, isNull);
    });
  });
}
