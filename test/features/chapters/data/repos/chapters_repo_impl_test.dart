import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/features/chapters/data/datasources/chapters_progress_local_datasource.dart';
import 'package:mishkat_almasabih/features/chapters/data/models/chapters_model.dart';
import 'package:mishkat_almasabih/features/chapters/data/repos/chapters_repo_impl.dart';
import 'package:mishkat_almasabih/features/chapters/domain/entities/book_chapter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiService extends Fake implements ApiService {
  Object? error;

  @override
  Future<ChaptersModel> getBookChapters(String bookSlug) async {
    if (error != null) throw error!;
    return const ChaptersModel(
      chapters: [Chapter(chapterNumber: 1, chapterArabic: 'كتاب الإيمان')],
    );
  }
}

void main() {
  final cache = GenericCacheService.instance;
  late _FakeApiService api;
  late ChaptersRepoImpl repo;

  setUpAll(() => SharedPreferences.setMockInitialValues({}));

  setUp(() {
    api = _FakeApiService();
    repo = ChaptersRepoImpl(api, cache, ChaptersProgressLocalDataSource());
  });

  tearDown(() => cache.clearCache(CacheKeys.chapters('bukhari')));

  test('getChapters maps and caches the chapters', () async {
    final result = await repo.getChapters('bukhari');

    expect((result as ApiSuccess<List<BookChapter>>).data.single.chapterNumber, 1);
    expect((await repo.getCachedChapters('bukhari'))?.single.chapterArabic, 'كتاب الإيمان');
  });

  test('offline, getChapters returns the chapters fetched before', () async {
    await repo.getChapters('bukhari');
    api.error = DioException(
      requestOptions: RequestOptions(path: '/chapters'),
      type: DioExceptionType.connectionError,
    );

    final result = await repo.getChapters('bukhari');

    expect((result as ApiSuccess<List<BookChapter>>).data.single.chapterArabic, 'كتاب الإيمان');
  });
}
