import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/audio/app_audio_player.dart';
import 'package:mishkat_almasabih/core/audio/audio_lengths_datasource.dart';
import 'package:mishkat_almasabih/core/domain/entities/media_command.dart';

/// Who takes the player in these tests. Standing by and stopping never
/// create just_audio's player, so no platform is needed.
final _quran = Object();
final _azkar = Object();

void main() {
  late AppAudioPlayer player;

  setUp(() => player = AppAudioPlayer(AudioLengthsDataSource(Dio())));

  /// Lets the stream events sent so far reach their listeners.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  /// Counts the takeovers [owner] is told of.
  int Function() takeoversOf(Object owner) {
    var count = 0;
    final subscription = player.takeoversOf(owner).listen((_) => count++);
    addTearDown(subscription.cancel);
    return () => count;
  }

  group('taking the player', () {
    test('tells the one it was taken from', () async {
      final quranTakeovers = takeoversOf(_quran);
      final azkarTakeovers = takeoversOf(_azkar);

      await player.standBy(_quran);
      await player.standBy(_azkar);
      await settle();

      expect(quranTakeovers(), 1);
      expect(azkarTakeovers(), 1);
    });

    test('tells an owner that never had it, to drop what it offers', () async {
      final quranTakeovers = takeoversOf(_quran);

      await player.standBy(_azkar);
      await settle();

      expect(quranTakeovers(), 1);
    });

    test('taken again by the same owner is no takeover for it', () async {
      final quranTakeovers = takeoversOf(_quran);

      await player.standBy(_quran);
      await player.standBy(_quran);
      await settle();

      expect(quranTakeovers(), 0);
    });

    test('hands the controls outside the app to the new owner', () async {
      final forQuran = <MediaCommand>[];
      final forAzkar = <MediaCommand>[];
      final quran = player.commandsOf(_quran).listen(forQuran.add);
      addTearDown(quran.cancel);
      final azkar = player.commandsOf(_azkar).listen(forAzkar.add);
      addTearDown(azkar.cancel);

      await player.standBy(_quran);
      await player.mediaSession.pause();
      await player.standBy(_azkar);
      await player.mediaSession.play();
      await settle();

      expect(forQuran, [MediaCommand.pause]);
      expect(forAzkar, [MediaCommand.play]);
    });
  });

  group('stopping', () {
    test('lets go of the player', () async {
      await player.standBy(_quran);

      await player.stop(_quran);

      expect(player.mediaSession.holder, isNull);
    });

    test('by one it was taken from, leaves the new owner be', () async {
      await player.standBy(_quran);
      await player.standBy(_azkar);

      await player.stop(_quran);

      expect(player.mediaSession.holder, same(_azkar));
    });

    test('the new owner keeps it though taken while stopping', () async {
      await player.standBy(_quran);

      final stopping = player.stop(_quran);
      await player.standBy(_azkar);
      await stopping;

      expect(player.mediaSession.holder, same(_azkar));
    });
  });
}
