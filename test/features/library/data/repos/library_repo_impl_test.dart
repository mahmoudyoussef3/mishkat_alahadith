import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/features/library/data/models/book_data_model.dart';
import 'package:mishkat_almasabih/features/library/data/models/library_statistics_model.dart';
import 'package:mishkat_almasabih/features/library/data/repos/library_repo_impl.dart';
import 'package:mishkat_almasabih/features/library/domain/entities/category_books.dart';
import 'package:mishkat_almasabih/features/library/domain/entities/library_statistics.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiService extends Fake implements ApiService {
  Object? error;

  @override
  Future<CategoryResponse> getBookData(String categoryId) async {
    if (error != null) throw error!;
    return const CategoryResponse(
      category: Category(id: 'c1', name: 'الكتب التسعة', books: ['bukhari']),
      books: [
        Book(bookName: 'Sahih Bukhari', bookSlug: 'bukhari', hadiths_count: 7563, chapters_count: 97),
      ],
    );
  }

  @override
  Future<StatisticsResponse> getLibraryStatisctics() async => StatisticsResponse(
    status: 200,
    statistics: Statistics(
      totalBooks: 17,
      totalHadiths: 40000,
      totalChapters: 900,
      booksByCategory: {
        'nine': BooksByCategory(name: 'التسعة', nameEn: 'Nine', nameUr: '', count: 9, hadiths: 30000),
      },
      topBooks: [TopBook(name: 'bukhari', hadiths: 7563, chapters: 97)],
      lastUpdated: '2026-01-01',
    ),
  );
}

void main() {
  final cache = GenericCacheService.instance;
  late _FakeApiService api;
  late LibraryRepoImpl repo;

  setUpAll(() => SharedPreferences.setMockInitialValues({}));

  setUp(() {
    api = _FakeApiService();
    repo = LibraryRepoImpl(api, cache);
  });

  tearDown(() async {
    await cache.clearCache(CacheKeys.bookData('c1'));
    await cache.clearCache(CacheKeys.libraryStatistics);
  });

  test('getCategoryBooks maps snake_case counts onto the entity', () async {
    final result = await repo.getCategoryBooks('c1');

    final data = (result as ApiSuccess<CategoryBooks>).data;
    expect(data.category?.bookSlugs, ['bukhari']);
    expect(data.books.single.hadithsCount, 7563);
    expect(data.books.single.chaptersCount, 97);
  });

  test('getCachedCategoryBooks returns what the last fetch saved', () async {
    expect(await repo.getCachedCategoryBooks('c1'), isNull);

    await repo.getCategoryBooks('c1');

    final cached = await repo.getCachedCategoryBooks('c1');
    expect(cached?.books.single.bookSlug, 'bukhari');
  });

  test('getCategoryBooks maps a dio failure to a typed Failure', () async {
    api.error = DioException(
      requestOptions: RequestOptions(path: '/books'),
      type: DioExceptionType.connectionError,
    );

    final result = await repo.getCategoryBooks('c1');

    expect((result as ApiFailure).failure, isA<NetworkFailure>());
  });

  test('getStatistics maps nested category and top-book stats', () async {
    final result = await repo.getStatistics();

    final stats = (result as ApiSuccess<LibraryStatistics>).data;
    expect(stats.totalBooks, 17);
    expect(stats.booksByCategory['nine']?.count, 9);
    expect(stats.topBooks.single.chapters, 97);
    expect((await repo.getCachedStatistics())?.totalHadiths, 40000);
  });
}
