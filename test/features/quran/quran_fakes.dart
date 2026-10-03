import 'dart:async';

import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/mushaf_reader_settings.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_ayah.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_bookmark.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_last_read.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_surah.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/tajweed_info.dart';
import 'package:mishkat_almasabih/features/quran/domain/repos/quran_reading_repo.dart';
import 'package:mishkat_almasabih/features/quran/domain/repos/quran_repo.dart';

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

  int allAyahsCalls = 0;
  final List<({int page, bool includeNaturalMadd})> countRequests = [];

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
  }) async => ApiResult.success(tajweed[ayahId] ?? const []);

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
