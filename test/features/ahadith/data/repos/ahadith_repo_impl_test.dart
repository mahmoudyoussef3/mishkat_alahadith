import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/features/ahadith/data/models/ahadiths_model.dart';
import 'package:mishkat_almasabih/features/ahadith/data/models/local_books_model.dart';
import 'package:mishkat_almasabih/features/ahadith/data/repos/ahadith_repo_impl.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/entities/chapter_ahadith_page.dart';
import 'package:mishkat_almasabih/core/domain/entities/chapter_hadith.dart';
import 'package:mishkat_almasabih/features/ahadith/domain/entities/local_book_hadith.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiService extends Fake implements ApiService {
  Object? error;

  @override
  Future<HadithResponse> getChapterAhadiths(
    String bookSlug,
    int chapterId,
    int page,
    int paginate,
  ) async => HadithResponse(
    hadiths: Hadiths(
      data: [
        Hadith(
          id: 7,
          hadithArabic: 'نص',
          book: HadithBook(writerName: 'البخاري'),
        ),
      ],
      last_page: 4,
      total: 40,
    ),
  );

  @override
  Future<LocalHadithResponse> getThreeBooksLocalChapterAhadiths(
    String bookSlug,
    int chapterId,
  ) async => error != null ? throw error! : LocalHadithResponse(
    hadiths: LocalHadithsWrapper(
      data: [
        LocalHadith(
          id: 1,
          arabic: 'إنما الأعمال',
          english: EnglishHadith(narrator: 'Umar', text: 'Actions'),
        ),
      ],
    ),
  );
}

DioException _offline() => DioException(
  requestOptions: RequestOptions(path: '/offline'),
  type: DioExceptionType.connectionError,
);

void main() {
  final cache = GenericCacheService.instance;
  late AhadithRepoImpl repo;

  setUpAll(() => SharedPreferences.setMockInitialValues({}));
  late _FakeApiService api;

  setUp(() {
    api = _FakeApiService();
    repo = AhadithRepoImpl(api, cache);
  });
  tearDown(() async {
    await cache.clearCache(CacheKeys.paginatedAhadith('bukhari', 1));
    await cache.clearCache(CacheKeys.arbainAhadith('nawawi40', 1));
  });

  test('getAhadithPage maps the page and its pagination totals', () async {
    final result = await repo.getAhadithPage(
      bookSlug: 'bukhari',
      chapterId: 1,
      page: 1,
      paginate: 10,
    );

    final page = (result as ApiSuccess<ChapterAhadithPage>).data;
    expect(page.ahadith.single.id, 7);
    expect(page.ahadith.single.book?.writerName, 'البخاري');
    expect(page.totalPages, 4);
    expect(page.total, 40);
  });

  test('cacheAhadith round-trips entities through the stored JSON format', () async {
    await repo.cacheAhadith(
      bookSlug: 'bukhari',
      chapterId: 1,
      ahadith: const [
        ChapterHadith(
          id: 7,
          hadithNumber: '12',
          chapter: HadithSourceChapter(chapterArabic: 'كتاب الإيمان'),
        ),
      ],
      lastLoadedPage: 2,
      totalCount: 40,
    );

    final cached = await repo.getCachedAhadith(bookSlug: 'bukhari', chapterId: 1);

    expect(cached?.lastLoadedPage, 2);
    expect(cached?.totalCount, 40);
    expect(cached?.ahadith.single.hadithNumber, '12');
    expect(cached?.ahadith.single.chapter?.chapterArabic, 'كتاب الإيمان');
  });

  test('getArbainAhadith flattens the English translation', () async {
    final result = await repo.getArbainAhadith(bookSlug: 'nawawi40', chapterId: 1);

    final hadith = (result as ApiSuccess<List<LocalBookHadith>>).data.single;
    expect(hadith.arabic, 'إنما الأعمال');
    expect(hadith.englishNarrator, 'Umar');
    expect(hadith.englishText, 'Actions');
  });

  test('getCachedAhadith still returns the pages read once they expire', () async {
    await cache.saveData<Map<String, dynamic>>(
      key: CacheKeys.paginatedAhadith('bukhari', 1),
      data: {
        'ahadith': [
          {'id': 7, 'hadithNumber': '12'},
        ],
        'lastPage': 1,
        'totalCount': 40,
        'cachedAt': 0,
      },
      toJson: (d) => d,
      cacheExpirationHours: 0,
    );

    final cached = await repo.getCachedAhadith(bookSlug: 'bukhari', chapterId: 1);

    expect(cached?.ahadith.single.id, 7);
  });

  test('offline, getArbainAhadith returns the chapter fetched before', () async {
    await repo.getArbainAhadith(bookSlug: 'nawawi40', chapterId: 1);
    api.error = _offline();

    final result = await repo.getArbainAhadith(bookSlug: 'nawawi40', chapterId: 1);

    expect((result as ApiSuccess<List<LocalBookHadith>>).data.single.arabic, 'إنما الأعمال');
  });
}
