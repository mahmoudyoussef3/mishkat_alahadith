import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_last_read.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/filter_surahs_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_juz_index_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_last_read_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_page_info_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_quran_bookmarks_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_surahs_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/remove_quran_bookmark_use_case.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_index/quran_index_cubit.dart';

import '../quran_fakes.dart';

QuranIndexCubit _cubit(FakeQuranRepo quran, FakeQuranReadingRepo reading) =>
    QuranIndexCubit(
      GetSurahsUseCase(quran),
      GetJuzIndexUseCase(quran),
      FilterSurahsUseCase(),
      GetQuranBookmarksUseCase(reading),
      RemoveQuranBookmarkUseCase(reading),
      GetLastReadUseCase(reading),
      GetPageInfoUseCase(quran),
    );

QuranIndexLoaded _loaded(QuranIndexCubit cubit) =>
    cubit.state as QuranIndexLoaded;

void main() {
  late FakeQuranRepo quran;
  late FakeQuranReadingRepo reading;

  setUp(() {
    quran = FakeQuranRepo();
    reading = FakeQuranReadingRepo();
  });

  test('load lists the surahs and ajzāʾ', () async {
    final cubit = _cubit(quran, reading);

    await cubit.load();

    expect(_loaded(cubit).surahs, sampleSurahs);
    expect(_loaded(cubit).visibleSurahs, sampleSurahs);
    expect(_loaded(cubit).juzList.map((j) => j.number), [1, 2, 6]);
    await cubit.close();
  });

  test('load describes the page the reader stopped on', () async {
    reading.lastRead = QuranLastRead(page: 22, savedAt: DateTime(2026));
    final cubit = _cubit(quran, reading);

    await cubit.load();

    expect(_loaded(cubit).lastRead?.page, 22);
    expect(_loaded(cubit).lastReadInfo?.openingSurah, baqarah);
    await cubit.close();
  });

  test('names the surah to resume even when its page details fail', () async {
    // The fake has no ayahs on page 30, so its page details cannot load.
    reading.lastRead = QuranLastRead(page: 30, savedAt: DateTime(2026));
    final cubit = _cubit(quran, reading);

    await cubit.load();

    expect(_loaded(cubit).lastReadInfo, isNull);
    expect(_loaded(cubit).resumeSurah, baqarah);
    await cubit.close();
  });

  test('offers Al-Fātiḥah before anything has been read', () async {
    final cubit = _cubit(quran, reading);

    await cubit.load();

    expect(_loaded(cubit).resumeSurah, fatihah);
    await cubit.close();
  });

  test('load fails when the surah table cannot be loaded', () async {
    quran.failSurahs = true;
    final cubit = _cubit(quran, reading);

    await cubit.load();

    expect(cubit.state, isA<QuranIndexFailure>());
    await cubit.close();
  });

  test('unreadable bookmarks leave the index usable', () async {
    reading.failReads = true;
    final cubit = _cubit(quran, reading);

    await cubit.load();

    expect(_loaded(cubit).bookmarks, isNull);
    expect(_loaded(cubit).surahs, isNotEmpty);
    await cubit.close();
  });

  test('filterSurahs narrows the visible surahs', () async {
    final cubit = _cubit(quran, reading);
    await cubit.load();

    cubit.filterSurahs('الناس');

    expect(_loaded(cubit).visibleSurahs, [nas]);
    expect(_loaded(cubit).query, 'الناس');
    await cubit.close();
  });

  test('clearing the filter brings every surah back', () async {
    final cubit = _cubit(quran, reading);
    await cubit.load();
    cubit.filterSurahs('الناس');

    cubit.filterSurahs('');

    expect(_loaded(cubit).visibleSurahs, sampleSurahs);
    await cubit.close();
  });

  test('removeBookmark removes it from the list', () async {
    reading.bookmarks = [pageBookmark(5), ayahBookmark(2)];
    final cubit = _cubit(quran, reading);
    await cubit.load();

    final removed = await cubit.removeBookmark(pageBookmark(5));

    expect(removed, isTrue);
    expect(_loaded(cubit).bookmarks?.single.ayahId, 2);
    await cubit.close();
  });

  test('refreshReadingData picks up where the reader stopped', () async {
    final cubit = _cubit(quran, reading);
    await cubit.load();
    reading.lastRead = QuranLastRead(page: 106, savedAt: DateTime(2026));

    await cubit.refreshReadingData();

    expect(_loaded(cubit).lastReadInfo?.openingSurah, nisa);
    await cubit.close();
  });
}
