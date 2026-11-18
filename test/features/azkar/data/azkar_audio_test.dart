import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_service/audio_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mishkat_almasabih/core/audio/app_audio_player.dart';
import 'package:mishkat_almasabih/core/audio/audio_lengths_datasource.dart';
import 'package:mishkat_almasabih/core/domain/entities/media_command.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/azkar/data/datasources/azkar_audio_cache_datasource.dart';
import 'package:mishkat_almasabih/features/azkar/data/datasources/azkar_audio_player_datasource.dart';
import 'package:mishkat_almasabih/features/azkar/data/datasources/azkar_preferences_local_datasource.dart';
import 'package:mishkat_almasabih/features/azkar/data/repos/azkar_audio_repo_impl.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Answers every request itself instead of going to the network.
class _FakeAdapter implements HttpClientAdapter {
  int statusCode = 200;
  bool offline = false;
  Completer<void>? gate;
  final List<String> urls = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    urls.add(options.uri.toString());
    await gate?.future;
    if (offline) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    return ResponseBody.fromBytes([1, 2, 3], statusCode);
  }

  @override
  void close({bool force = false}) {}
}

/// A player driven by the test, with no platform behind it.
class _FakePlayer extends AzkarAudioPlayerDataSource {
  _FakePlayer() : super(AppAudioPlayer(AudioLengthsDataSource(Dio())));

  final StreamController<PlayerState> states = StreamController.broadcast();
  final StreamController<PlayerException> failures =
      StreamController.broadcast();
  final StreamController<MediaCommand> controls = StreamController.broadcast();
  final StreamController<void> takenOver = StreamController.broadcast();
  final List<MediaItem> played = [];
  int standBys = 0;

  @override
  Stream<PlayerState> get playerStates => states.stream;

  @override
  Stream<PlayerException> get errors => failures.stream;

  @override
  Stream<MediaCommand> get commands => controls.stream;

  @override
  Stream<void> get takeovers => takenOver.stream;

  @override
  Future<void> playFile(MediaItem item) async => played.add(item);

  @override
  Future<void> standBy() async => standBys++;

  @override
  Future<void> stop() async {}
}

const _morningZikr = AzkarAudioTrack(
  audioFile: '75.mp3',
  categoryId: 27,
  zikrId: 3,
  categoryTitle: 'أذكار الصباح والمساء',
  zikrNumber: 3,
);

void main() {
  late Directory root;
  late _FakeAdapter adapter;
  late AzkarAudioCacheDataSource cache;

  setUp(() {
    root = Directory.systemTemp.createTempSync('azkar_audio_test');
    adapter = _FakeAdapter();
    cache = AzkarAudioCacheDataSource(
      Dio()..httpClientAdapter = adapter,
      cacheRoot: () async => root,
    );
  });

  tearDown(() => root.deleteSync(recursive: true));

  group('AzkarAudioCacheDataSource', () {
    test('downloads a file from the pinned CDN path', () async {
      final path = await cache.resolve('75.mp3');

      expect(
        adapter.urls.single,
        '${AzkarAudioCacheDataSource.baseUrl}/75.mp3',
      );
      expect(File(path).readAsBytesSync(), [1, 2, 3]);
    });

    test('plays a downloaded file from the device afterwards', () async {
      await cache.resolve('75.mp3');
      await cache.resolve('75.mp3');

      expect(adapter.urls, hasLength(1));
    });

    test('shares one download between requests made together', () async {
      adapter.gate = Completer();
      final first = cache.resolve('75.mp3');
      final second = cache.resolve('75.mp3');
      adapter.gate!.complete();

      expect(await first, await second);
      expect(adapter.urls, hasLength(1));
    });

    test('leaves nothing behind when a download fails', () async {
      adapter.offline = true;

      await expectLater(cache.resolve('75.mp3'), throwsA(isA<DioException>()));

      expect(Directory('${root.path}/azkar_audio').listSync(), isEmpty);
    });

    test('abandons a download that is no longer wanted', () async {
      adapter.gate = Completer();
      final abandoned = cache.resolve('75.mp3');
      await pumpEventQueue();

      cache.cancelDownloads();

      await expectLater(
        abandoned,
        throwsA(
          isA<DioException>().having(
            (e) => e.type,
            'type',
            DioExceptionType.cancel,
          ),
        ),
      );
      adapter.gate!.complete();
    });

    test('keeps the download it is told to keep', () async {
      adapter.gate = Completer();
      final kept = cache.resolve('75.mp3');
      await pumpEventQueue();

      cache.cancelDownloads(except: '75.mp3');
      adapter.gate!.complete();

      expect(await kept, endsWith('75.mp3'));
    });

    test('refuses anything but a plain mp3 file name', () {
      expect(cache.resolve('../secrets.mp3'), throwsArgumentError);
      expect(cache.resolve('75.wav'), throwsArgumentError);
      expect(adapter.urls, isEmpty);
    });
  });

  group('AzkarAudioRepoImpl.watchStatus', () {
    late _FakePlayer player;
    late AzkarAudioRepoImpl repo;

    setUp(() {
      player = _FakePlayer();
      repo = AzkarAudioRepoImpl(
        cache,
        player,
        AzkarPreferencesLocalDataSource(),
      );
    });

    test('reads the player\'s states as playback statuses', () async {
      final statuses = <AzkarPlaybackStatus>[];
      final listening = repo.watchStatus().listen(statuses.add);

      player.states
        ..add(PlayerState(false, ProcessingState.loading))
        ..add(PlayerState(true, ProcessingState.ready))
        ..add(PlayerState(false, ProcessingState.ready))
        ..add(PlayerState(true, ProcessingState.completed));
      await pumpEventQueue();

      expect(statuses, [
        AzkarPlaybackStatus.loading,
        AzkarPlaybackStatus.playing,
        AzkarPlaybackStatus.paused,
        AzkarPlaybackStatus.completed,
      ]);
      await listening.cancel();
    });

    test('passes a player failure on as an error', () async {
      final errors = <Object>[];
      final listening = repo.watchStatus().listen((_) {}, onError: errors.add);

      player.failures.add(PlayerException(0, 'decoder failed', 0));
      await pumpEventQueue();

      expect(errors.single, isA<UnexpectedFailure>());
      await listening.cancel();
    });
  });

  group('AzkarAudioRepoImpl.prepare', () {
    late AzkarAudioRepoImpl repo;

    setUp(
      () =>
          repo = AzkarAudioRepoImpl(
            cache,
            _FakePlayer(),
            AzkarPreferencesLocalDataSource(),
          ),
    );

    test('succeeds with where the file is kept', () async {
      final path = dataOf(await repo.prepare('75.mp3'));

      expect(path, '${root.path}/azkar_audio/75.mp3');
    });

    test('says a file missing upstream is unavailable', () async {
      adapter.statusCode = 404;

      final result = await repo.prepare('153.mp3');

      final failure = (result as ApiFailure).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.message, FailureMessages.audioUnavailable);
    });

    test('a new request abandons the one before it', () async {
      adapter.gate = Completer();
      final older = repo.prepare('75.mp3');
      await pumpEventQueue();

      final newer = repo.prepare('76.mp3');
      adapter.gate!.complete();

      expect(await older, isA<ApiFailure>());
      expect(dataOf(await newer), endsWith('76.mp3'));
    });

    test('says so when there is no connection', () async {
      adapter.offline = true;

      final result = await repo.prepare('75.mp3');

      expect((result as ApiFailure).failure, isA<NetworkFailure>());
    });
  });

  group('AzkarAudioRepoImpl on the app\'s player', () {
    late _FakePlayer player;
    late AzkarAudioRepoImpl repo;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      player = _FakePlayer();
      repo = AzkarAudioRepoImpl(
        cache,
        player,
        AzkarPreferencesLocalDataSource(),
      );
    });

    test('plays the file on the device, named as the zikr is', () async {
      await repo.play('/cache/azkar_audio/75.mp3', _morningZikr);

      final item = player.played.single;
      expect(item.id, Uri.file('/cache/azkar_audio/75.mp3').toString());
      expect(item.title, 'الذكر ٣ · أذكار الصباح والمساء');
      expect(item.album, 'حصن المسلم');
    });

    test('standing by reaches the player', () async {
      await repo.standBy();

      expect(player.standBys, 1);
    });

    test('controls used outside the app and takeovers are passed on', () async {
      final heard = <MediaCommand>[];
      var takeovers = 0;
      final commands = repo.commands().listen(heard.add);
      final taken = repo.takenOver().listen((_) => takeovers++);

      player.controls.add(MediaCommand.pause);
      player.takenOver.add(null);
      await pumpEventQueue();

      expect(heard, [MediaCommand.pause]);
      expect(takeovers, 1);
      await commands.cancel();
      await taken.cancel();
    });

    test('keeps the recitation for after the app is closed', () async {
      await repo.saveLastTrack(_morningZikr);

      final kept = dataOf(await repo.getLastTrack())!;
      expect(kept, _morningZikr);
      expect(kept.title, _morningZikr.title);
    });

    test('forgets it once ended', () async {
      await repo.saveLastTrack(_morningZikr);

      await repo.saveLastTrack(null);

      expect(dataOf(await repo.getLastTrack()), isNull);
    });

    test('a damaged entry is nothing to offer again', () async {
      SharedPreferences.setMockInitialValues({'azkar_last_audio': '{"x":1}'});

      expect(dataOf(await repo.getLastTrack()), isNull);
    });
  });
}

T dataOf<T>(ApiResult<T> result) => (result as ApiSuccess<T>).data;
