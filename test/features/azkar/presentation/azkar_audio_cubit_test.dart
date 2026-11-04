import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_audio.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/pause_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/play_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/prepare_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/resume_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/stop_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/watch_azkar_playback_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_audio/azkar_audio_cubit.dart';

import '../azkar_fakes.dart';

const _first = AzkarAudioTrack(audioFile: '75.mp3', categoryId: 27, zikrId: 1);
const _second = AzkarAudioTrack(audioFile: '76.mp3', categoryId: 27, zikrId: 2);

void main() {
  late FakeAzkarAudioRepo player;
  late AzkarAudioCubit cubit;

  setUp(() {
    player = FakeAzkarAudioRepo();
    cubit = AzkarAudioCubit(
      PrepareAzkarAudioUseCase(player),
      PlayAzkarAudioUseCase(player),
      PauseAzkarAudioUseCase(player),
      ResumeAzkarAudioUseCase(player),
      StopAzkarAudioUseCase(player),
      WatchAzkarPlaybackUseCase(player),
    );
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

  test('closing the screen stops the player', () async {
    await cubit.play(_first);
    final stopsBefore = player.stops;

    await cubit.close();

    expect(player.stops, stopsBefore + 1);
  });
}
