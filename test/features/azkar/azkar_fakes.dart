import 'dart:async';

import 'package:mishkat_almasabih/core/domain/entities/media_command.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_audio.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_category.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_day_progress.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_settings.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/zikr.dart';
import 'package:mishkat_almasabih/features/azkar/domain/repos/azkar_audio_repo.dart';
import 'package:mishkat_almasabih/features/azkar/domain/repos/azkar_repo.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/get_azkar_catalog_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/get_azkar_settings_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/get_favorite_azkar_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/get_suggested_azkar_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/get_today_azkar_progress_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/last_azkar_audio_use_cases.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/pause_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/play_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/prepare_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/reset_azkar_category_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/resume_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/save_azkar_settings_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/search_azkar_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/set_zikr_count_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/stand_by_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/stop_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/toggle_favorite_azkar_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/watch_azkar_audio_commands_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/watch_azkar_audio_taken_over_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/watch_azkar_playback_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_audio/azkar_audio_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_home/azkar_home_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_reader/azkar_reader_cubit.dart';

T dataOf<T>(ApiResult<T> result) => switch (result) {
  ApiSuccess(:final data) => data,
  ApiFailure(:final failure) => throw StateError('Expected data: $failure'),
};

/// 07:00 on 5 November 2026: morning.
DateTime morningClock() => DateTime(2026, 11, 5, 7);

const morningEvening = AzkarCategory(
  id: 27,
  title: 'أذكار الصباح والمساء',
  audioFile: 'ar_7esn_AlMoslem_by_Doors_028.mp3',
  azkar: [
    Zikr(
      id: 1,
      text: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيطَانِ الرَّجِيمِ',
      count: 1,
      audioFile: '75.mp3',
    ),
    Zikr(
      id: 2,
      text: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      count: 3,
      audioFile: '76.mp3',
    ),
    Zikr(id: 3, text: 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ', count: 100),
  ],
);

const sleep = AzkarCategory(
  id: 28,
  title: 'أذكار النوم',
  azkar: [
    Zikr(id: 1, text: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا', count: 1),
  ],
);

const afterPrayer = AzkarCategory(
  id: 25,
  title: 'الأذكار بعد السلام من الصلاة',
  azkar: [Zikr(id: 1, text: 'أَسْتَغْفِرُ اللَّهَ', count: 3)],
);

const travel = AzkarCategory(
  id: 96,
  title: 'دعاء السفر',
  azkar: [Zikr(id: 1, text: 'اللَّهُ أَكْبَرُ، اللَّهُ أَكْبَرُ', count: 1)],
);

const sampleCatalog = [morningEvening, sleep, afterPrayer, travel];

/// [sampleCatalog] as it reads with the English translation shown.
final List<AzkarCategory> sampleCatalogEnglish = [
  for (final category in sampleCatalog)
    AzkarCategory(
      id: category.id,
      title: category.title,
      translatedTitle: 'Chapter ${category.id}',
      audioFile: category.audioFile,
      azkar: [
        for (final zikr in category.azkar)
          Zikr(
            id: zikr.id,
            text: zikr.text,
            count: zikr.count,
            audioFile: zikr.audioFile,
            translation: 'Meaning ${category.id}.${zikr.id}',
          ),
      ],
    ),
];

/// Keeps everything in memory, and fails on request.
class FakeAzkarRepo implements AzkarRepo {
  bool failCatalog = false;
  bool failFavorites = false;
  bool failFavoriteReads = false;
  bool failProgressWrites = false;
  bool failSettingsSave = false;

  /// Catalogue loads that wait until the test completes them.
  final Map<AzkarTranslation, Completer<void>> catalogHolds = {};

  List<int> favoriteIds = [];
  AzkarDayProgress? progress;
  AzkarSettings settings = AzkarSettings.defaults;
  final List<AzkarTranslation> catalogRequests = [];
  int progressWrites = 0;

  @override
  Future<ApiResult<List<AzkarCategory>>> getCategories(
    AzkarTranslation translation,
  ) async {
    catalogRequests.add(translation);
    await catalogHolds[translation]?.future;
    if (failCatalog) return const ApiResult.failure(CacheFailure());
    return ApiResult.success(
      translation == AzkarTranslation.none
          ? sampleCatalog
          : sampleCatalogEnglish,
    );
  }

  @override
  Future<ApiResult<List<int>>> getFavoriteIds() async {
    if (failFavorites || failFavoriteReads) {
      return const ApiResult.failure(CacheFailure());
    }
    return ApiResult.success(favoriteIds);
  }

  @override
  Future<ApiResult<List<int>>> updateFavoriteIds(
    List<int> Function(List<int> current) change,
  ) async {
    if (failFavorites) return const ApiResult.failure(CacheFailure());
    favoriteIds = change(favoriteIds);
    return ApiResult.success(favoriteIds);
  }

  @override
  Future<ApiResult<AzkarDayProgress?>> getProgress() async =>
      ApiResult.success(progress);

  @override
  Future<ApiResult<AzkarDayProgress>> updateProgress(
    AzkarDayProgress Function(AzkarDayProgress? stored) change,
  ) async {
    progressWrites++;
    if (failProgressWrites) return const ApiResult.failure(CacheFailure());
    final updated = change(progress);
    progress = updated;
    return ApiResult.success(updated);
  }

  @override
  Future<ApiResult<AzkarSettings>> getSettings() async =>
      ApiResult.success(settings);

  @override
  Future<ApiResult<void>> saveSettings(AzkarSettings settings) async {
    if (failSettingsSave) return const ApiResult.failure(CacheFailure());
    this.settings = settings;
    return const ApiResult.success(null);
  }
}

/// A player driven by the test: statuses, controls used outside the app and
/// takeovers by the Quran are pushed in by hand, and downloads can be held
/// until the test answers them.
class FakeAzkarAudioRepo implements AzkarAudioRepo {
  final StreamController<AzkarPlaybackStatus> statuses =
      StreamController.broadcast();
  final StreamController<MediaCommand> controls = StreamController.broadcast();
  final StreamController<void> takeovers = StreamController.broadcast();

  bool holdDownloads = false;
  final Map<String, Completer<ApiResult<String>>> pendingDownloads = {};
  Failure? downloadFailure;

  final List<String> played = [];
  final List<AzkarAudioTrack> playedTracks = [];
  int pauses = 0;
  int resumes = 0;
  int standBys = 0;
  int stops = 0;

  /// The recitation kept for after the app is closed, and every one kept
  /// since — null for each time it was forgotten.
  AzkarAudioTrack? lastTrack;
  final List<AzkarAudioTrack?> savedTracks = [];

  void finishDownload(String audioFile) => pendingDownloads
      .remove(audioFile)!
      .complete(ApiResult.success('/cache/$audioFile'));

  @override
  Future<ApiResult<String>> prepare(String audioFile) {
    if (holdDownloads) {
      return (pendingDownloads[audioFile] = Completer()).future;
    }
    final failure = downloadFailure;
    return Future.value(
      failure == null
          ? ApiResult.success('/cache/$audioFile')
          : ApiResult.failure(failure),
    );
  }

  @override
  Future<ApiResult<void>> play(String localPath, AzkarAudioTrack track) async {
    played.add(localPath);
    playedTracks.add(track);
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> standBy() async {
    standBys++;
    return const ApiResult.success(null);
  }

  @override
  Stream<MediaCommand> commands() => controls.stream;

  @override
  Stream<void> takenOver() => takeovers.stream;

  @override
  Future<ApiResult<AzkarAudioTrack?>> getLastTrack() async =>
      ApiResult.success(lastTrack);

  @override
  Future<ApiResult<void>> saveLastTrack(AzkarAudioTrack? track) async {
    lastTrack = track;
    savedTracks.add(track);
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> pause() async {
    pauses++;
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> resume() async {
    resumes++;
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> stop() async {
    stops++;
    return const ApiResult.success(null);
  }

  @override
  Stream<AzkarPlaybackStatus> watchStatus() => statuses.stream;
}

AzkarReaderCubit readerCubitFor(
  FakeAzkarRepo repo, {
  DateTime Function() now = morningClock,
}) => AzkarReaderCubit(
  GetAzkarCatalogUseCase(repo),
  GetTodayAzkarProgressUseCase(repo, now: now),
  SetZikrCountUseCase(repo, now: now),
  ResetAzkarCategoryUseCase(repo, now: now),
  GetFavoriteAzkarUseCase(repo),
  ToggleFavoriteAzkarUseCase(repo),
  GetAzkarSettingsUseCase(repo),
  SaveAzkarSettingsUseCase(repo),
);

AzkarHomeCubit homeCubitFor(
  FakeAzkarRepo repo, {
  DateTime Function() now = morningClock,
}) => AzkarHomeCubit(
  GetAzkarCatalogUseCase(repo),
  SearchAzkarUseCase(),
  GetSuggestedAzkarUseCase(now: now),
  GetTodayAzkarProgressUseCase(repo, now: now),
  GetFavoriteAzkarUseCase(repo),
  ToggleFavoriteAzkarUseCase(repo),
  GetAzkarSettingsUseCase(repo),
);

/// An audio cubit over [player].
AzkarAudioCubit audioCubitFor(FakeAzkarAudioRepo player) => AzkarAudioCubit(
  PrepareAzkarAudioUseCase(player),
  PlayAzkarAudioUseCase(player),
  PauseAzkarAudioUseCase(player),
  ResumeAzkarAudioUseCase(player),
  StopAzkarAudioUseCase(player),
  WatchAzkarPlaybackUseCase(player),
  StandByAzkarAudioUseCase(player),
  WatchAzkarAudioCommandsUseCase(player),
  WatchAzkarAudioTakenOverUseCase(player),
  GetLastAzkarAudioUseCase(player),
  SaveLastAzkarAudioUseCase(player),
);
