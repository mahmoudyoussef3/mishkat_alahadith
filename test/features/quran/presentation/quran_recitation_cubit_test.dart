import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation_settings.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/recitation/quran_recitation_cubit.dart';

import '../quran_fakes.dart';

void main() {
  late FakeQuranCloudRepo cloud;
  late FakeQuranReadingRepo reading;
  late FakeRecitationPlayerRepo player;
  late QuranRecitationCubit cubit;

  setUp(() {
    cloud = FakeQuranCloudRepo(
      recitations: {
        const RecitationScope.surah(1): audioFor([1, 2]),
        const RecitationScope.surah(2): audioFor([8, 149]),
      },
    );
    reading = FakeQuranReadingRepo();
    player = FakeRecitationPlayerRepo();
    cubit = recitationCubit(cloud: cloud, reading: reading, player: player);
  });

  tearDown(() => cubit.close());

  RecitationActive active() => cubit.state as RecitationActive;

  /// Starts at [ayahId] and lets the player report it is playing there.
  Future<void> playing(int ayahId, {int trackIndex = 0}) async {
    await cubit.start(RecitationFromAyah(ayahId));
    player.report(RecitationStatus.playing, trackIndex);
    await pumpEventQueue();
  }

  test('reads the saved settings', () async {
    reading.recitationSettings = const RecitationSettings(
      reciterId: 'ar.husary',
      reciterName: 'محمود خليل الحصري',
    );

    await cubit.init();

    expect(cubit.state.settings.reciterId, 'ar.husary');
    expect(cubit.state, isA<RecitationIdle>());
  });

  test('starts the recitation the mushaf was opened with', () async {
    await cubit.init(autoplay: const RecitationFromAyah(2));

    expect(player.plays.single.startIndex, 1);
  });

  test('recites the surah from the ayah asked for', () async {
    await cubit.start(const RecitationFromAyah(2));

    expect(active().playlist.scope, const RecitationScope.surah(1));
    expect(active().currentTrack.ayahId, 2);
    expect(active().status, RecitationStatus.loading);
    expect(player.plays.single.startIndex, 1);
  });

  test('silences whatever was playing before fetching, standing by', () async {
    await cubit.start(const RecitationFromAyah(1));

    // Not stopped: what the system shows outside the app stays up.
    expect((player.standBys, player.stops), (1, 0));
  });

  test('stands by when carrying on into the next surah', () async {
    await playing(2, trackIndex: 1);
    final standBysBefore = player.standBys;
    final stopsBefore = player.stops;

    player.report(RecitationStatus.completed, 1);
    await pumpEventQueue();

    expect(player.standBys, standBysBefore + 1);
    expect(player.stops, stopsBefore);
  });

  test('names its reciter to the player', () async {
    reading.recitationSettings = const RecitationSettings(
      reciterId: 'ar.husary',
      reciterName: 'محمود خليل الحصري',
    );

    await cubit.start(const RecitationFromAyah(1));

    expect(player.plays.single.reciterName, 'محمود خليل الحصري');
  });

  test('follows the player from ayah to ayah', () async {
    await playing(1);

    player.report(RecitationStatus.playing, 1);
    await pumpEventQueue();

    expect(active().currentTrack.ayahId, 2);
    expect(active().isPlaying, isTrue);
  });

  test('shows a recitation held back while starting as paused', () async {
    player.playGate = Completer();
    final starting = cubit.start(const RecitationFromAyah(1));
    await pumpEventQueue();

    player.report(RecitationStatus.paused, 0);
    await pumpEventQueue();
    expect(active().status, RecitationStatus.loading);

    player.playGate!.complete();
    await starting;

    expect(active().status, RecitationStatus.paused);
  });

  test('starts on its own ayah whatever the queue it replaced said', () async {
    player.playGate = Completer();
    final starting = cubit.start(const RecitationFromAyah(2));
    await pumpEventQueue();

    // Still about the queue being replaced, which was on its first ayah.
    player.report(RecitationStatus.playing, 0);
    await pumpEventQueue();
    player.playGate!.complete();
    await starting;

    expect(active().currentTrack.ayahId, 2);
    expect(active().isPlaying, isTrue);
  });

  test('carries on into the next surah when one ends', () async {
    await playing(2, trackIndex: 1);

    player.report(RecitationStatus.completed, 1);
    await pumpEventQueue();

    expect(active().playlist.scope, const RecitationScope.surah(2));
    expect(player.plays.last.startIndex, 0);
  });

  test('comes to rest at the end when not carrying on', () async {
    reading.recitationSettings = const RecitationSettings(continuous: false);
    await cubit.init();
    await playing(2, trackIndex: 1);
    final stopsBefore = player.stops;

    player.report(RecitationStatus.completed, 1);
    await pumpEventQueue();

    expect(cubit.state, isA<RecitationIdle>());
    expect(player.stops, stopsBefore + 1);
  });

  test('fetches the next surah while the last ayah plays', () async {
    await playing(1);

    player.report(RecitationStatus.playing, 1);
    await pumpEventQueue();

    expect(
      cloud.recitationRequests.where(
        (r) => r.scope == const RecitationScope.surah(2),
      ),
      hasLength(1),
    );
  });

  test('says why when the recitation cannot be fetched', () async {
    cloud.failure = const NetworkFailure();

    await cubit.start(const RecitationFromAyah(1));

    expect(
      (cubit.state as RecitationFailure).message,
      FailureMessages.noConnection,
    );
    expect(player.plays, isEmpty);
  });

  test('tries the same recitation again after a failure', () async {
    cloud.failure = const NetworkFailure();
    await cubit.start(const RecitationFromAyah(2));
    cloud.failure = null;

    await cubit.togglePlayPause();

    expect(active().currentTrack.ayahId, 2);
  });

  test('a player error while playing fails once and silences it', () async {
    await playing(1);
    final failures = <QuranRecitationState>[];
    final sub = cubit.stream
        .where((s) => s is RecitationFailure)
        .listen(failures.add);
    final stopsBefore = player.stops;

    player.reportError();
    player.reportError();
    await pumpEventQueue();
    await sub.cancel();

    expect(failures, hasLength(1));
    expect(player.stops, stopsBefore + 1);
  });

  test(
    'a failure to start is reported once, not again by the player',
    () async {
      player
        ..failPlay = true
        ..playGate = Completer();
      final failures = <QuranRecitationState>[];
      final sub = cubit.stream
          .where((s) => s is RecitationFailure)
          .listen(failures.add);

      final starting = cubit.start(const RecitationFromAyah(1));
      await pumpEventQueue();
      player.reportError();
      player.playGate!.complete();
      await starting;
      await pumpEventQueue();
      await sub.cancel();

      expect(failures, hasLength(1));
    },
  );

  test('drops a recitation that arrives after a newer request', () async {
    cloud.recitationGates[const RecitationScope.surah(1)] = Completer();
    final first = cubit.start(const RecitationFromAyah(1));
    await pumpEventQueue();

    await cubit.start(const RecitationFromAyah(8));
    cloud.recitationGates[const RecitationScope.surah(1)]!.complete();
    await first;

    expect(player.plays, hasLength(1));
    expect(active().playlist.scope, const RecitationScope.surah(2));
  });

  test('an ayah in the playlist is skipped to, not fetched again', () async {
    await playing(1);

    await cubit.playAyah(2);

    expect(player.skips, [1]);
    expect(cloud.recitationRequests, hasLength(1));
    expect(active().currentTrack.ayahId, 2);
  });

  test('an ayah outside the playlist starts its own surah', () async {
    await playing(1);

    await cubit.playAyah(8);

    expect(active().playlist.scope, const RecitationScope.surah(2));
  });

  test('a paused recitation resumes at the ayah picked in it', () async {
    await playing(1);
    await cubit.pause();

    await cubit.playAyah(2);

    expect(player.resumes, 1);
    expect(active().isPlaying, isTrue);
  });

  test('pauses and resumes', () async {
    await playing(1);

    await cubit.togglePlayPause();
    expect(active().status, RecitationStatus.paused);
    expect(player.pauses, 1);

    await cubit.togglePlayPause();
    expect(active().isPlaying, isTrue);
    expect(player.resumes, 1);
  });

  test('the next ayah after the last starts the next surah', () async {
    await playing(2, trackIndex: 1);

    await cubit.next();

    expect(active().playlist.scope, const RecitationScope.surah(2));
  });

  test('the ayah before the first restarts it', () async {
    await playing(1);

    await cubit.previous();

    expect(player.skips, [0]);
    expect(active().trackIndex, 0);
  });

  test('a new repetition queues the playlist again at the same ayah', () async {
    await playing(1, trackIndex: 1);
    player.report(RecitationStatus.playing, 1);
    await pumpEventQueue();

    final saved = await cubit.setRepeat(AyahRepeat.thrice);

    expect(saved, isTrue);
    expect(player.plays, hasLength(2));
    expect(player.plays.last.startIndex, 1);
    expect(player.plays.last.repeat, AyahRepeat.thrice);
    // Queued again from what is loaded, not fetched again.
    expect(
      cloud.recitationRequests.where(
        (r) => r.scope == const RecitationScope.surah(1),
      ),
      hasLength(1),
    );
    expect(reading.savedRecitationSettings.last.repeat, AyahRepeat.thrice);
  });

  test('a new repetition keeps a paused recitation paused', () async {
    await playing(1);
    await cubit.pause();

    await cubit.setRepeat(AyahRepeat.twice);

    expect(player.plays.last.paused, isTrue);
    expect(active().status, RecitationStatus.paused);
  });

  test('another reciter keeps a paused recitation paused', () async {
    await playing(1);
    await cubit.pause();

    await cubit.setReciter(husary);
    await pumpEventQueue();

    expect(player.plays.last.paused, isTrue);
    expect(active().status, RecitationStatus.paused);
  });

  test('another reciter picked while fetching is the one played', () async {
    final gate = Completer<void>();
    cloud.recitationGates[const RecitationScope.surah(1)] = gate;
    final first = cubit.start(const RecitationFromAyah(1));
    await pumpEventQueue();

    await cubit.setReciter(husary);
    await pumpEventQueue();
    gate.complete();
    await first;
    await pumpEventQueue();

    expect(cloud.recitationRequests.map((r) => r.reciter), [
      'ar.alafasy',
      'ar.husary',
    ]);
    // Only the fetch for the reciter picked reaches the player.
    expect(player.plays, hasLength(1));
  });

  test('stopped while the player is being set up, it stays silent', () async {
    player.playGate = Completer();
    final starting = cubit.start(const RecitationFromAyah(1));
    await pumpEventQueue();

    await cubit.stop();
    final stopsAfterStop = player.stops;
    player.playGate!.complete();
    await starting;
    await pumpEventQueue();

    expect(cubit.state, isA<RecitationIdle>());
    expect(player.stops, stopsAfterStop + 1);
  });

  test(
    'replaced while the player is being set up, the new one plays',
    () async {
      final gate = Completer<void>();
      player.playGate = gate;
      final first = cubit.start(const RecitationFromAyah(1));
      await pumpEventQueue();

      player.playGate = null;
      await cubit.start(const RecitationFromAyah(8));
      final stopsBefore = player.stops;
      // The first play returns only now, after the second reached the player.
      gate.complete();
      await first;

      expect(player.stops, stopsBefore);
      expect(active().playlist.scope, const RecitationScope.surah(2));
    },
  );

  test(
    'replaced while being set up by one still fetching, it stands by',
    () async {
      final gate = Completer<void>();
      player.playGate = gate;
      final first = cubit.start(const RecitationFromAyah(1));
      await pumpEventQueue();

      cloud.recitationGates[const RecitationScope.surah(2)] = Completer();
      final second = cubit.start(const RecitationFromAyah(8));
      await pumpEventQueue();
      final standBysBefore = player.standBys;
      final stopsBefore = player.stops;
      gate.complete();
      await first;

      // Silenced for the one on its way, without taking the controls down.
      expect(player.standBys, standBysBefore + 1);
      expect(player.stops, stopsBefore);

      player.playGate = null;
      cloud.recitationGates[const RecitationScope.surah(2)]!.complete();
      await second;
    },
  );

  group('controls outside the app', () {
    test('pause and play as the buttons in the app do', () async {
      await playing(1);

      player.command(RecitationCommand.pause);
      await pumpEventQueue();
      expect(active().status, RecitationStatus.paused);
      expect(player.pauses, 1);

      player.command(RecitationCommand.play);
      await pumpEventQueue();
      expect(active().isPlaying, isTrue);
      expect(player.resumes, 1);
    });

    test('move to the next and the previous ayah', () async {
      await playing(1);

      player.command(RecitationCommand.next);
      await pumpEventQueue();
      expect(active().currentTrack.ayahId, 2);

      player.command(RecitationCommand.previous);
      await pumpEventQueue();
      expect(active().currentTrack.ayahId, 1);
      expect(player.skips, [1, 0]);
    });

    test('next on the last ayah carries on into the next surah', () async {
      await playing(2, trackIndex: 1);

      player.command(RecitationCommand.next);
      await pumpEventQueue();

      expect(active().playlist.scope, const RecitationScope.surah(2));
    });

    test('stop ends the recitation', () async {
      await playing(1);
      final stopsBefore = player.stops;

      player.command(RecitationCommand.stop);
      await pumpEventQueue();

      expect(cubit.state, isA<RecitationIdle>());
      expect(player.stops, stopsBefore + 1);
    });

    test('play tries again after a failure', () async {
      cloud.failure = const NetworkFailure();
      await cubit.start(const RecitationFromAyah(2));
      cloud.failure = null;

      player.command(RecitationCommand.play);
      await pumpEventQueue();

      expect(active().currentTrack.ayahId, 2);
    });

    test('a pause between one surah and the next brings it paused', () async {
      await playing(2, trackIndex: 1);
      cloud.recitationGates[const RecitationScope.surah(2)] = Completer();
      player.report(RecitationStatus.completed, 1);
      await pumpEventQueue();
      expect(cubit.state, isA<RecitationPreparing>());

      player.command(RecitationCommand.pause);
      await pumpEventQueue();
      cloud.recitationGates[const RecitationScope.surah(2)]!.complete();
      await pumpEventQueue();

      expect(active().playlist.scope, const RecitationScope.surah(2));
      expect(active().status, RecitationStatus.paused);
      expect(player.plays.last.paused, isTrue);
      // Fetched ahead and as it ended, but not again for the pause.
      expect(
        cloud.recitationRequests.where(
          (r) => r.scope == const RecitationScope.surah(2),
        ),
        hasLength(2),
      );
    });

    test(
      'play after such a pause, before the surah arrives, plays it',
      () async {
        await playing(2, trackIndex: 1);
        cloud.recitationGates[const RecitationScope.surah(2)] = Completer();
        player.report(RecitationStatus.completed, 1);
        await pumpEventQueue();

        player
          ..command(RecitationCommand.pause)
          ..command(RecitationCommand.play);
        await pumpEventQueue();
        cloud.recitationGates[const RecitationScope.surah(2)]!.complete();
        await pumpEventQueue();

        expect(active().playlist.scope, const RecitationScope.surah(2));
        expect(player.plays.last.paused, isFalse);
      },
    );

    test('play while idle does nothing', () async {
      await playing(1);
      await cubit.stop();

      player.command(RecitationCommand.play);
      await pumpEventQueue();

      expect(cubit.state, isA<RecitationIdle>());
    });

    test('are no longer heard once the mushaf closes', () async {
      await playing(1);
      await cubit.close();
      final pausesBefore = player.pauses;

      player.command(RecitationCommand.pause);
      await pumpEventQueue();

      expect(player.pauses, pausesBefore);
    });
  });

  test('a new speed reaches the recitation as it plays', () async {
    await playing(1);

    await cubit.setSpeed(RecitationSpeed.faster);

    expect(player.speeds, [RecitationSpeed.faster]);
    expect(player.plays, hasLength(1));
  });

  test('another reciter takes over at the same ayah', () async {
    await playing(1);
    player.report(RecitationStatus.playing, 1);
    await pumpEventQueue();

    await cubit.setReciter(husary);
    await pumpEventQueue();

    expect(cloud.recitationRequests.last.reciter, 'ar.husary');
    expect(player.plays.last.startIndex, 1);
    expect(cubit.state.settings.reciterName, husary.name);
  });

  test('a setting changed while idle only waits for next time', () async {
    final saved = await cubit.setContinuous(false);

    expect(saved, isTrue);
    expect(cubit.state.settings.continuous, isFalse);
    expect(player.plays, isEmpty);
  });

  test('a setting that cannot be saved still applies now', () async {
    reading.failWrites = true;

    final saved = await cubit.setSpeed(RecitationSpeed.slower);

    expect(saved, isFalse);
    expect(cubit.state.settings.speed, RecitationSpeed.slower);
  });

  test('stops', () async {
    await playing(1);

    await cubit.stop();

    expect(cubit.state, isA<RecitationIdle>());
  });

  test('ignores playback reported after it stopped', () async {
    await playing(1);
    await cubit.stop();

    player.report(RecitationStatus.playing, 1);
    await pumpEventQueue();

    expect(cubit.state, isA<RecitationIdle>());
  });

  test('silences the player when the mushaf closes', () async {
    await playing(1);
    final stopsBefore = player.stops;

    await cubit.close();

    expect(player.stops, stopsBefore + 1);
  });

  group('recitingAyahOn', () {
    test('names the ayah being recited on its own page', () async {
      await playing(1);

      expect(cubit.state.recitingAyahOn(1), 1);
      expect(cubit.state.recitingAyahOn(2), isNull);
    });

    test('names none while idle', () {
      expect(cubit.state.recitingAyahOn(1), isNull);
    });
  });

  group('the azkar taking the player', () {
    test('ends the recitation, leaving the player to them', () async {
      await playing(1);
      final stopsBefore = player.stops;

      player.takeOver();
      await pumpEventQueue();

      expect(cubit.state, isA<RecitationIdle>());
      expect(player.stops, stopsBefore);
    });

    test('a playlist arriving after it is never played', () async {
      cloud.recitationGates[const RecitationScope.surah(1)] = Completer();
      final starting = cubit.start(const RecitationFromAyah(1));
      await pumpEventQueue();

      player.takeOver();
      await pumpEventQueue();
      cloud.recitationGates[const RecitationScope.surah(1)]!.complete();
      await starting;

      expect(player.plays, isEmpty);
      expect(cubit.state, isA<RecitationIdle>());
    });

    test('is nothing to a cubit with nothing on', () async {
      await cubit.init();

      player.takeOver();
      await pumpEventQueue();

      expect(cubit.state, isA<RecitationIdle>());
      expect(reading.savedResumePoints, isEmpty);
    });
  });

  group('picking up after the app was closed', () {
    const leftOff = RecitationResumePoint(
      scope: RecitationScope.surah(1),
      track: RecitationTrack(
        ayahId: 2,
        surahNumber: 1,
        surahName: 'الفاتحة',
        ayahNumber: 2,
        page: 1,
        url: 'https://cdn.example/2.mp3',
      ),
    );

    test('keeps where the recitation is as it moves on', () async {
      await playing(1);
      player.report(RecitationStatus.playing, 1);
      await pumpEventQueue();

      final kept = reading.resumePoint!;
      expect(kept.scope, const RecitationScope.surah(1));
      expect(kept.track.ayahId, 2);
    });

    test('writes each ayah once, whatever its status', () async {
      await playing(1);
      final writes = reading.savedResumePoints.length;

      player.report(RecitationStatus.paused, 0);
      await pumpEventQueue();
      player.report(RecitationStatus.playing, 0);
      await pumpEventQueue();

      expect(reading.savedResumePoints, hasLength(writes));
    });

    test('forgets it once stopped', () async {
      await playing(1);

      await cubit.stop();

      expect(reading.savedResumePoints.last, isNull);
      expect(reading.resumePoint, isNull);
    });

    test('forgets it once the azkar take the player', () async {
      await playing(1);

      player.takeOver();
      await pumpEventQueue();

      expect(reading.resumePoint, isNull);
    });

    test('keeps a failed recitation, to be tried again', () async {
      await playing(1);

      player.reportError();
      await pumpEventQueue();

      expect(cubit.state, isA<RecitationFailure>());
      expect(reading.resumePoint?.track.ayahId, 1);
    });

    test('offers the recitation left off, held', () async {
      reading.resumePoint = leftOff;

      await cubit.restore();

      final state = cubit.state as RecitationSuspended;
      expect(state.point, leftOff);
      expect(state.currentTrack.ayahId, 2);
      expect(player.plays, isEmpty);
      expect(player.standBys, 0);
    });

    test('the ayah offered is not shown as being recited', () async {
      reading.resumePoint = leftOff;

      await cubit.restore();

      expect(cubit.state.recitingAyahOn(1), isNull);
    });

    test('offers nothing when the last recitation was ended', () async {
      await cubit.restore();

      expect(cubit.state, isA<RecitationIdle>());
    });

    test('offers nothing once something else was asked for', () async {
      reading.resumePoint = leftOff;
      await playing(1);

      await cubit.restore();

      expect(cubit.state, isA<RecitationActive>());
    });

    test('playing picks it up at the ayah it was on', () async {
      reading.resumePoint = leftOff;
      await cubit.restore();

      await cubit.togglePlayPause();

      expect(player.plays.single.startIndex, 1);
      expect(cubit.state, isA<RecitationActive>());
    });

    test('play outside the app picks it up too', () async {
      reading.resumePoint = leftOff;
      await cubit.restore();
      await cubit.start(const RecitationFromAyah(1));
      await cubit.stop();
      reading.resumePoint = leftOff;
      await cubit.restore();

      player.command(RecitationCommand.play);
      await pumpEventQueue();

      expect(player.plays.last.startIndex, 1);
    });

    test('closing it forgets it', () async {
      reading.resumePoint = leftOff;
      await cubit.restore();

      await cubit.stop();

      expect(cubit.state, isA<RecitationIdle>());
      expect(reading.resumePoint, isNull);
    });

    test('the azkar taking the player drop it', () async {
      reading.resumePoint = leftOff;
      await cubit.restore();

      player.takeOver();
      await pumpEventQueue();

      expect(cubit.state, isA<RecitationIdle>());
      expect(reading.resumePoint, isNull);
    });
  });
}
