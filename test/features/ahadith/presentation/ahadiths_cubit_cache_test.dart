import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/domain/entities/chapter_hadith.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
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

const _kept = [ChapterHadith(id: 1), ChapterHadith(id: 2), ChapterHadith(id: 3)];
const _freshPage = [ChapterHadith(id: 1), ChapterHadith(id: 9)];

/// A chapter kept on the device, and a server that answers page 1 or not.
class _CachedRepo extends Fake implements AhadithRepo {
  _CachedRepo({required this.isStale, required this.online});

  final bool isStale;
  final bool online;

  @override
  Future<CachedChapterAhadith?> getCachedAhadith({
    required String bookSlug,
    required int chapterId,
  }) async => CachedChapterAhadith(
    ahadith: _kept,
    lastLoadedPage: 2,
    totalCount: 30,
    isStale: isStale,
  );

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
  }) async =>
      online
          ? const ApiResult.success(
            ChapterAhadithPage(ahadith: _freshPage, totalPages: 3, total: 30),
          )
          : const ApiResult.failure(NetworkFailure());

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

/// The ids shown once the refresh after the cached chapter has settled.
Future<List<int?>> _shownAfterRefresh(_CachedRepo repo) async {
  final cubit = AhadithsCubit(
    GetCachedChapterAhadithUseCase(repo),
    CacheChapterAhadithUseCase(repo),
    GetChapterAhadithPageUseCase(repo),
    GetLocalAhadithUseCase(repo),
    GetArbainAhadithUseCase(repo),
  );
  addTearDown(cubit.close);
  final settled = cubit.stream.firstWhere(
    (state) => state is AhadithsSuccess && !state.isRefreshing,
  );
  await cubit.emitAhadiths(
    bookSlug: 'bukhari',
    chapterId: 1,
    hadithLocal: false,
    isArbainBooks: false,
    page: 1,
  );
  final state = await settled as AhadithsSuccess;
  return [for (final hadith in state.allAhadith) hadith.id];
}

void main() {
  test('a fresh kept chapter is merged with the refreshed first page', () async {
    final shown = await _shownAfterRefresh(_CachedRepo(isStale: false, online: true));

    expect(shown, [1, 9, 2, 3]);
  });

  test('an expired kept chapter is replaced by the refreshed first page', () async {
    final shown = await _shownAfterRefresh(_CachedRepo(isStale: true, online: true));

    expect(shown, [1, 9]);
  });

  test('offline, an expired kept chapter stays on screen', () async {
    final shown = await _shownAfterRefresh(_CachedRepo(isStale: true, online: false));

    expect(shown, [1, 2, 3]);
  });
}
