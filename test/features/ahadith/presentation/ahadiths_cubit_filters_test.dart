import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/domain/entities/chapter_hadith.dart';
import 'package:mishkat_almasabih/core/helpers/hadith_grade.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/entities/chapter_ahadith_page.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/entities/local_book_hadith.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/repos/ahadith_repo.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/usecases/cache_chapter_ahadith_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/usecases/get_arbain_ahadith_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/usecases/get_cached_chapter_ahadith_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/usecases/get_chapter_ahadith_page_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/usecases/get_local_ahadith_use_case.dart';
import 'package:mishkat_almasabih/features/ahadith/presentation/logic/cubit/ahadiths_cubit.dart';

ChapterHadith _hadith(int id, String text, String status) =>
    ChapterHadith(id: id, hadithArabic: text, status: status);

/// Two pages of a remote chapter: one sahih and one da'if hadith each.
class _PagedRepo implements AhadithRepo {
  static final pages = {
    1: [_hadith(1, 'إنما الأعمال بالنيات', 'Sahih'), _hadith(2, 'حديث آخر', 'Da\'if')],
    2: [_hadith(3, 'الأعمال الصالحة', 'Sahih'), _hadith(4, 'نص ثالث', 'Da\'if')],
  };

  @override
  Future<CachedChapterAhadith?> getCachedAhadith({
    required String bookSlug,
    required int chapterId,
  }) async => null;

  @override
  Future<void> cacheAhadith({
    required String bookSlug,
    required int chapterId,
    required List<ChapterHadith> ahadith,
    required int lastLoadedPage,
    required int totalCount,
  }) async {}

  @override
  Future<ApiResult<ChapterAhadithPage>> getAhadithPage({
    required String bookSlug,
    required int chapterId,
    required int page,
    required int paginate,
  }) async => ApiResult.success(
    ChapterAhadithPage(ahadith: pages[page]!, totalPages: 2, total: 4),
  );

  @override
  Future<ApiResult<List<LocalBookHadith>>> getLocalAhadith({
    required String bookSlug,
    required int chapterId,
  }) async => const ApiResult.success([]);

  @override
  Future<ApiResult<List<LocalBookHadith>>> getArbainAhadith({
    required String bookSlug,
    required int chapterId,
  }) async => const ApiResult.success([]);
}

AhadithsCubit _cubit() {
  final repo = _PagedRepo();
  return AhadithsCubit(
    GetCachedChapterAhadithUseCase(repo),
    CacheChapterAhadithUseCase(repo),
    GetChapterAhadithPageUseCase(repo),
    GetLocalAhadithUseCase(repo),
    GetArbainAhadithUseCase(repo),
  );
}

Future<void> _load(AhadithsCubit cubit, int page) => cubit.emitAhadiths(
  bookSlug: 'sahih-bukhari',
  chapterId: 1,
  hadithLocal: false,
  isArbainBooks: false,
  page: page,
);

List<int?> _shownIds(AhadithsCubit cubit) =>
    (cubit.state as AhadithsSuccess).filteredAhadith.map((h) => h.id).toList();

void main() {
  late AhadithsCubit cubit;

  setUp(() => cubit = _cubit());
  tearDown(() => cubit.close());

  test('reports the chapter total from the API', () async {
    await _load(cubit, 1);

    expect((cubit.state as AhadithsSuccess).totalCount, 4);
  });

  test('a search stays applied when the next page loads', () async {
    await _load(cubit, 1);
    cubit.filterAhadith('الأعمال');

    await _load(cubit, 2);

    expect(_shownIds(cubit), [1, 3]);
  });

  test('a grade filter shows only hadiths of that grade', () async {
    await _load(cubit, 1);

    cubit.filterByGrade(HadithGrade.daif);

    expect(_shownIds(cubit), [2]);
    expect((cubit.state as AhadithsSuccess).gradeFilter, HadithGrade.daif);
  });

  test('search and grade filters combine', () async {
    await _load(cubit, 1);
    await _load(cubit, 2);

    cubit.filterByGrade(HadithGrade.sahih);
    cubit.filterAhadith('الصالحة');

    expect(_shownIds(cubit), [3]);
  });

  test('clearing the grade filter shows every hadith again', () async {
    await _load(cubit, 1);
    cubit.filterByGrade(HadithGrade.sahih);

    cubit.filterByGrade(null);

    expect(_shownIds(cubit), [1, 2]);
  });
}
