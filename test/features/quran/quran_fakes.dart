import 'dart:async';

import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/mushaf_reader_settings.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_commentary.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition_search.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_hizb_quarter.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation_settings.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_ayah.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_bookmark.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_last_read.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_surah.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/tajweed_info.dart';
import 'package:mishkat_almasabih/features/quran/domain/repos/quran_cloud_repo.dart';
import 'package:mishkat_almasabih/features/quran/domain/repos/quran_reading_repo.dart';
import 'package:mishkat_almasabih/features/quran/domain/repos/quran_recitation_player_repo.dart';
import 'package:mishkat_almasabih/features/quran/domain/repos/quran_repo.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/load_recitation_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/quran_study_settings_use_cases.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/recitation_player_use_cases.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/recitation_resume_use_cases.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/recitation/quran_recitation_cubit.dart';

const fatihah = QuranSurah(
  number: 1,
  nameArabic: 'الفاتحة',
  nameEnglish: 'Al-Fātiḥah',
  ayahCount: 7,
  startPage: 1,
  endPage: 1,
);
const baqarah = QuranSurah(
  number: 2,
  nameArabic: 'البقرة',
  nameEnglish: 'Al-Baqarah',
  ayahCount: 286,
  startPage: 2,
  endPage: 49,
);
const nisa = QuranSurah(
  number: 4,
  nameArabic: 'النساء',
  nameEnglish: 'An-Nisā’',
  ayahCount: 176,
  startPage: 77,
  endPage: 106,
);
const maidah = QuranSurah(
  number: 5,
  nameArabic: 'المائدة',
  nameEnglish: 'Al-Mā’idah',
  ayahCount: 120,
  startPage: 106,
  endPage: 127,
);
const nas = QuranSurah(
  number: 114,
  nameArabic: 'الناس',
  nameEnglish: 'An-Nās',
  ayahCount: 6,
  startPage: 604,
  endPage: 604,
);

const sampleSurahs = [fatihah, baqarah, nisa, maidah, nas];

const basmalah = QuranAyah(
  id: 1,
  surahNumber: 1,
  number: 1,
  juz: 1,
  page: 1,
  text: 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ',
);
const hamd = QuranAyah(
  id: 2,
  surahNumber: 1,
  number: 2,
  juz: 1,
  page: 1,
  text: 'ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَٰلَمِينَ',
);
const alifLamMeem = QuranAyah(
  id: 8,
  surahNumber: 2,
  number: 1,
  juz: 1,
  page: 2,
  text: 'الٓمٓ',
);
const sayaqulu = QuranAyah(
  id: 149,
  surahNumber: 2,
  number: 142,
  juz: 2,
  page: 22,
  text: 'سَيَقُولُ ٱلسُّفَهَآءُ مِنَ ٱلنَّاسِ',
);
const nisaLast = QuranAyah(
  id: 669,
  surahNumber: 4,
  number: 176,
  juz: 6,
  page: 106,
  text: 'يَسۡتَفۡتُونَكَ قُلِ ٱللَّهُ يُفۡتِيكُمۡ',
);
const maidahFirst = QuranAyah(
  id: 670,
  surahNumber: 5,
  number: 1,
  juz: 6,
  page: 106,
  text: 'يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوٓاْ أَوۡفُواْ بِٱلۡعُقُودِۚ',
);

const sampleAyahs = [
  basmalah,
  hamd,
  alifLamMeem,
  sayaqulu,
  nisaLast,
  maidahFirst,
];

/// The bundled-text repository, served from memory.
class FakeQuranRepo implements QuranRepo {
  List<QuranSurah> surahs;
  List<QuranAyah> ayahs;
  Map<int, List<TajweedSegment>> tajweed;
  Map<int, List<TajweedRuleCount>> pageCounts;
  bool failSurahs;
  bool failAyahs;
  bool failCounts;
  bool failTajweed;

  int allAyahsCalls = 0;
  final List<({int page, bool includeNaturalMadd})> countRequests = [];
  final List<({int ayahId, bool includeNaturalMadd})> tajweedRequests = [];

  /// Per-page gates for [getPageAyahs], to order concurrent loads.
  final Map<int, Completer<void>> pageGates = {};

  FakeQuranRepo({
    this.surahs = sampleSurahs,
    this.ayahs = sampleAyahs,
    this.tajweed = const {},
    this.pageCounts = const {},
    this.failSurahs = false,
    this.failAyahs = false,
    this.failCounts = false,
    this.failTajweed = false,
  });

  @override
  Future<ApiResult<List<QuranSurah>>> getSurahs() async =>
      failSurahs
          ? const ApiResult.failure(CacheFailure('no surahs'))
          : ApiResult.success(surahs);

  @override
  Future<ApiResult<List<QuranAyah>>> getAllAyahs() async {
    allAyahsCalls++;
    return failAyahs
        ? const ApiResult.failure(CacheFailure('no ayahs'))
        : ApiResult.success(ayahs);
  }

  @override
  Future<ApiResult<List<QuranAyah>>> getPageAyahs(int page) async {
    await pageGates[page]?.future;
    if (failAyahs) return const ApiResult.failure(CacheFailure('no ayahs'));
    return ApiResult.success(ayahs.where((a) => a.page == page).toList());
  }

  @override
  Future<ApiResult<QuranAyah>> getAyah(int ayahId) async {
    final ayah = ayahs.where((a) => a.id == ayahId).firstOrNull;
    return ayah == null
        ? const ApiResult.failure(UnexpectedFailure())
        : ApiResult.success(ayah);
  }

  @override
  Future<ApiResult<List<TajweedSegment>>> getAyahTajweed(
    int ayahId, {
    required bool includeNaturalMadd,
  }) async {
    tajweedRequests.add((
      ayahId: ayahId,
      includeNaturalMadd: includeNaturalMadd,
    ));
    if (failTajweed) return const ApiResult.failure(CacheFailure('no rules'));
    return ApiResult.success(tajweed[ayahId] ?? const []);
  }

  @override
  Future<ApiResult<List<TajweedRuleCount>>> getPageTajweedCounts(
    int page, {
    required bool includeNaturalMadd,
  }) async {
    countRequests.add((page: page, includeNaturalMadd: includeNaturalMadd));
    if (failCounts) return const ApiResult.failure(CacheFailure('no counts'));
    return ApiResult.success(pageCounts[page] ?? const []);
  }
}

/// The reader's saved data, kept in memory.
class FakeQuranReadingRepo implements QuranReadingRepo {
  QuranLastRead? lastRead;
  List<QuranBookmark> bookmarks;
  MushafReaderSettings settings;
  bool failReads;
  bool failWrites;

  final List<int> savedPages = [];
  final List<MushafReaderSettings> savedSettings = [];

  FakeQuranReadingRepo({
    this.lastRead,
    List<QuranBookmark>? bookmarks,
    this.settings = MushafReaderSettings.defaults,
    this.failReads = false,
    this.failWrites = false,
  }) : bookmarks = bookmarks ?? [];

  @override
  Future<ApiResult<QuranLastRead?>> getLastRead() async =>
      failReads
          ? const ApiResult.failure(CacheFailure())
          : ApiResult.success(lastRead);

  @override
  Future<ApiResult<void>> saveLastRead(QuranLastRead lastRead) async {
    if (failWrites) return const ApiResult.failure(CacheFailure());
    this.lastRead = lastRead;
    savedPages.add(lastRead.page);
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<List<QuranBookmark>>> getBookmarks() async =>
      failReads
          ? const ApiResult.failure(CacheFailure())
          : ApiResult.success(List.of(bookmarks));

  @override
  Future<ApiResult<List<QuranBookmark>>> updateBookmarks(
    List<QuranBookmark> Function(List<QuranBookmark> current) change,
  ) async {
    if (failReads || failWrites) return const ApiResult.failure(CacheFailure());
    bookmarks = change(List.of(bookmarks));
    return ApiResult.success(List.of(bookmarks));
  }

  @override
  Future<ApiResult<MushafReaderSettings>> getSettings() async =>
      failReads
          ? const ApiResult.failure(CacheFailure())
          : ApiResult.success(settings);

  @override
  Future<ApiResult<void>> saveSettings(MushafReaderSettings settings) async {
    if (failWrites) return const ApiResult.failure(CacheFailure());
    this.settings = settings;
    savedSettings.add(settings);
    return const ApiResult.success(null);
  }

  RecitationSettings recitationSettings = RecitationSettings.defaults;
  CommentarySettings commentarySettings = CommentarySettings.defaults;
  final List<RecitationSettings> savedRecitationSettings = [];
  final List<CommentarySettings> savedCommentarySettings = [];

  @override
  Future<ApiResult<RecitationSettings>> getRecitationSettings() async =>
      failReads
          ? const ApiResult.failure(CacheFailure())
          : ApiResult.success(recitationSettings);

  @override
  Future<ApiResult<void>> saveRecitationSettings(
    RecitationSettings settings,
  ) async {
    if (failWrites) return const ApiResult.failure(CacheFailure());
    recitationSettings = settings;
    savedRecitationSettings.add(settings);
    return const ApiResult.success(null);
  }

  /// Where the last recitation was left off, and every one kept since —
  /// null for each time it was forgotten.
  RecitationResumePoint? resumePoint;
  final List<RecitationResumePoint?> savedResumePoints = [];

  @override
  Future<ApiResult<RecitationResumePoint?>> getRecitationResumePoint() async =>
      failReads
          ? const ApiResult.failure(CacheFailure())
          : ApiResult.success(resumePoint);

  @override
  Future<ApiResult<void>> saveRecitationResumePoint(
    RecitationResumePoint? point,
  ) async {
    if (failWrites) return const ApiResult.failure(CacheFailure());
    resumePoint = point;
    savedResumePoints.add(point);
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<CommentarySettings>> getCommentarySettings() async =>
      failReads
          ? const ApiResult.failure(CacheFailure())
          : ApiResult.success(commentarySettings);

  @override
  Future<ApiResult<void>> saveCommentarySettings(
    CommentarySettings settings,
  ) async {
    if (failWrites) return const ApiResult.failure(CacheFailure());
    commentarySettings = settings;
    savedCommentarySettings.add(settings);
    return const ApiResult.success(null);
  }
}

// ── the online service ──────────────────────────────────────────────────

const alafasy = QuranEdition(
  identifier: 'ar.alafasy',
  name: 'مشاري العفاسي',
  englishName: 'Alafasy',
  language: 'ar',
  type: QuranEditionType.recitation,
  isRightToLeft: true,
);
const husary = QuranEdition(
  identifier: 'ar.husary',
  name: 'محمود خليل الحصري',
  englishName: 'Husary',
  language: 'ar',
  type: QuranEditionType.recitation,
  isRightToLeft: true,
);
const muyassar = QuranEdition(
  identifier: 'ar.muyassar',
  name: 'التفسير الميسر',
  englishName: 'King Fahad Quran Complex',
  language: 'ar',
  type: QuranEditionType.tafsir,
  isRightToLeft: true,
);
const jalalayn = QuranEdition(
  identifier: 'ar.jalalayn',
  name: 'تفسير الجلالين',
  englishName: 'Jalal ad-Din al-Mahalli and Jalal ad-Din as-Suyuti',
  language: 'ar',
  type: QuranEditionType.tafsir,
  isRightToLeft: true,
);
const sahih = QuranEdition(
  identifier: 'en.sahih',
  name: 'Saheeh International',
  englishName: 'Saheeh International',
  language: 'en',
  type: QuranEditionType.translation,
  isRightToLeft: false,
);

/// The reciter's audio for [ayahIds], at the service's address pattern.
List<RecitationAudio> audioFor(
  Iterable<int> ayahIds, {
  String reciter = 'ar.alafasy',
}) => [
  for (final id in ayahIds)
    RecitationAudio(
      ayahId: id,
      url: 'https://cdn.islamic.network/quran/audio/128/$reciter/$id.mp3',
      lowBitrateUrls: [
        'https://cdn.islamic.network/quran/audio/64/$reciter/$id.mp3',
      ],
    ),
];

EditionText passage(QuranEdition edition, String text) =>
    EditionText(edition: edition, text: text);

/// AlQuran Cloud, served from memory. Every call fails with [failure] when
/// it is set.
class FakeQuranCloudRepo implements QuranCloudRepo {
  Failure? failure;
  Map<QuranEditionType, List<QuranEdition>> editions;
  Map<RecitationScope, List<RecitationAudio>> recitations;
  Map<int, List<EditionText>> ayahTexts;
  List<AyahEditionText> surahTexts;
  List<AyahEditionMatch> searchMatches;
  AyahEditionText? random;
  List<QuranAyahRef>? hizbStarts;

  final List<({String reciter, RecitationScope scope})> recitationRequests = [];
  final List<({int ayahId, List<String> editions})> ayahTextRequests = [];
  final List<({int surah, int offset, int limit})> surahTextRequests = [];
  final List<({String query, String edition, int offset, int limit})>
  searchRequests = [];

  /// Per-scope gates for [getRecitation], to order concurrent loads.
  final Map<RecitationScope, Completer<void>> recitationGates = {};

  FakeQuranCloudRepo({
    this.failure,
    Map<QuranEditionType, List<QuranEdition>>? editions,
    Map<RecitationScope, List<RecitationAudio>>? recitations,
    this.ayahTexts = const {},
    this.surahTexts = const [],
    this.searchMatches = const [],
    this.random,
    this.hizbStarts,
  }) : editions =
           editions ??
           {
             QuranEditionType.recitation: [alafasy, husary],
             QuranEditionType.tafsir: [muyassar, jalalayn],
             QuranEditionType.translation: [sahih],
           },
       recitations = recitations ?? {};

  ApiResult<T>? _failed<T>() {
    final failure = this.failure;
    return failure == null ? null : ApiResult.failure(failure);
  }

  @override
  Future<ApiResult<List<QuranEdition>>> getEditions(
    QuranEditionType type,
  ) async => _failed() ?? ApiResult.success(editions[type] ?? const []);

  @override
  Future<ApiResult<List<RecitationAudio>>> getRecitation(
    String reciterId,
    RecitationScope scope,
  ) async {
    recitationRequests.add((reciter: reciterId, scope: scope));
    await recitationGates[scope]?.future;
    final failed = _failed<List<RecitationAudio>>();
    if (failed != null) return failed;
    final audio = recitations[scope];
    return audio == null
        ? const ApiResult.failure(
          ServerFailure(FailureMessages.audioUnavailable),
        )
        : ApiResult.success(audio);
  }

  @override
  Future<ApiResult<List<EditionText>>> getAyahTexts(
    int ayahId,
    List<String> editionIds,
  ) async {
    ayahTextRequests.add((ayahId: ayahId, editions: editionIds));
    return _failed() ??
        ApiResult.success([
          for (final text in ayahTexts[ayahId] ?? const <EditionText>[])
            if (editionIds.contains(text.edition.identifier)) text,
        ]);
  }

  @override
  Future<ApiResult<List<AyahEditionText>>> getSurahTexts(
    int surahNumber,
    List<String> editionIds, {
    required int offset,
    required int limit,
  }) async {
    surahTextRequests.add((surah: surahNumber, offset: offset, limit: limit));
    return _failed() ??
        ApiResult.success([
          for (final entry in surahTexts)
            if (editionIds.contains(entry.text.edition.identifier)) entry,
        ]);
  }

  @override
  Future<ApiResult<EditionSearchMatches>> searchEdition(
    String query,
    String editionId, {
    required int offset,
    required int limit,
  }) async {
    searchRequests.add((
      query: query,
      edition: editionId,
      offset: offset,
      limit: limit,
    ));
    final failed = _failed<EditionSearchMatches>();
    if (failed != null) return failed;
    final page = searchMatches.skip(offset).take(limit).toList();
    return ApiResult.success(
      EditionSearchMatches(matches: page, total: searchMatches.length),
    );
  }

  @override
  Future<ApiResult<AyahEditionText>> getRandomAyahText(String editionId) async {
    final failed = _failed<AyahEditionText>();
    if (failed != null) return failed;
    final random = this.random;
    return random == null
        ? const ApiResult.failure(ServerFailure())
        : ApiResult.success(random);
  }

  @override
  Future<ApiResult<List<QuranAyahRef>>> getHizbQuarterStarts() async {
    final failed = _failed<List<QuranAyahRef>>();
    if (failed != null) return failed;
    final starts = hizbStarts;
    return starts == null
        ? const ApiResult.failure(ServerFailure())
        : ApiResult.success(starts);
  }
}

/// The recitation player, recording what it was asked to do. Playback is
/// reported by calling [report], and controls used outside the app by
/// calling [command].
class FakeRecitationPlayerRepo implements QuranRecitationPlayerRepo {
  final StreamController<RecitationPlayback> _playback =
      StreamController.broadcast();
  final StreamController<RecitationCommand> _commands =
      StreamController.broadcast();
  final StreamController<void> _takeovers = StreamController.broadcast();

  final List<
    ({
      List<RecitationTrack> tracks,
      String reciterName,
      int startIndex,
      AyahRepeat repeat,
      RecitationSpeed speed,
      bool paused,
    })
  >
  plays = [];
  final List<int> skips = [];
  final List<RecitationSpeed> speeds = [];
  int pauses = 0;
  int resumes = 0;
  int standBys = 0;
  int stops = 0;
  bool failPlay = false;

  /// Holds [play] until completed, to order it against other calls.
  Completer<void>? playGate;

  void report(RecitationStatus status, [int? trackIndex]) =>
      _playback.add(RecitationPlayback(status: status, trackIndex: trackIndex));

  void reportError() =>
      _playback.addError(const UnexpectedFailure(FailureMessages.audio));

  void command(RecitationCommand command) => _commands.add(command);

  /// A recitation of the azkar takes the player.
  void takeOver() => _takeovers.add(null);

  @override
  Future<ApiResult<void>> play(
    List<RecitationTrack> tracks, {
    required String reciterName,
    required int startIndex,
    required AyahRepeat repeat,
    required RecitationSpeed speed,
    bool paused = false,
  }) async {
    plays.add((
      tracks: tracks,
      reciterName: reciterName,
      startIndex: startIndex,
      repeat: repeat,
      speed: speed,
      paused: paused,
    ));
    await playGate?.future;
    return failPlay
        ? const ApiResult.failure(UnexpectedFailure(FailureMessages.audio))
        : const ApiResult.success(null);
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
  Future<ApiResult<void>> standBy() async {
    standBys++;
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> stop() async {
    stops++;
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> skipTo(int index) async {
    skips.add(index);
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> setSpeed(RecitationSpeed speed) async {
    speeds.add(speed);
    return const ApiResult.success(null);
  }

  @override
  Stream<RecitationPlayback> watch() => _playback.stream;

  @override
  Stream<RecitationCommand> commands() => _commands.stream;

  @override
  Stream<void> takenOver() => _takeovers.stream;
}

/// A recitation cubit over fakes.
QuranRecitationCubit recitationCubit({
  FakeQuranCloudRepo? cloud,
  FakeQuranRepo? quran,
  FakeQuranReadingRepo? reading,
  FakeRecitationPlayerRepo? player,
}) {
  final readingRepo = reading ?? FakeQuranReadingRepo();
  final playerRepo = player ?? FakeRecitationPlayerRepo();
  return QuranRecitationCubit(
    GetRecitationSettingsUseCase(readingRepo),
    SaveRecitationSettingsUseCase(readingRepo),
    LoadRecitationUseCase(
      cloud ?? FakeQuranCloudRepo(),
      quran ?? FakeQuranRepo(),
    ),
    PlayRecitationUseCase(playerRepo),
    PauseRecitationUseCase(playerRepo),
    ResumeRecitationUseCase(playerRepo),
    StopRecitationUseCase(playerRepo),
    SkipToRecitationTrackUseCase(playerRepo),
    SetRecitationSpeedUseCase(playerRepo),
    WatchRecitationUseCase(playerRepo),
    StandByRecitationUseCase(playerRepo),
    WatchRecitationCommandsUseCase(playerRepo),
    WatchRecitationTakenOverUseCase(playerRepo),
    GetRecitationResumePointUseCase(readingRepo),
    SaveRecitationResumePointUseCase(readingRepo),
  );
}

QuranBookmark pageBookmark(int page, {DateTime? at}) => QuranBookmark(
  page: page,
  surahNumber: 2,
  surahName: 'البقرة',
  createdAt: at ?? DateTime(2026, 1, 1),
);

QuranBookmark ayahBookmark(int ayahId, {int page = 1, DateTime? at}) =>
    QuranBookmark(
      page: page,
      ayahId: ayahId,
      ayahNumber: ayahId,
      surahNumber: 1,
      surahName: 'الفاتحة',
      createdAt: at ?? DateTime(2026, 1, 1),
    );

T dataOf<T>(ApiResult<T> result) => (result as ApiSuccess<T>).data;
