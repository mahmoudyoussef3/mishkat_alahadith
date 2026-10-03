import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/core/networking/network_info.dart';
import 'package:mishkat_almasabih/core/domain/entities/chapter_hadith.dart';
import 'package:mishkat_almasabih/features/search_with_filters/data/models/search_with_filters_model.dart';
import 'package:mishkat_almasabih/features/search_with_filters/data/repos/search_with_filters_repo_impl.dart';
import 'package:mishkat_almasabih/features/search_with_filters/domain/entities/hadith_search_filters.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiService extends Fake implements ApiService {
  int calls = 0;

  @override
  Future<SearchWithFiltersModel> searchWithFilters(
    String searchQuery,
    String bookSlug,
    String narrator,
    String grade,
    String chapter,
    String category,
  ) async {
    calls++;
    return SearchWithFiltersModel(
      search: SearchData(
        results: SearchResults(
          data: [
            HadithResult(
              id: 1,
              hadithArabic: 'الدين النصيحة',
              book: Book(writerName: 'مسلم'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FakeNetworkInfo implements NetworkInfo {
  bool connected = true;

  @override
  Future<bool> get isConnected async => connected;
}

const _filters = HadithSearchFilters(
  query: 'النصيحة',
  bookSlug: '',
  narrator: '',
  grade: '',
  chapter: '',
  category: '',
);

void main() {
  final cache = GenericCacheService.instance;
  late _FakeApiService api;
  late _FakeNetworkInfo network;
  late SearchWithFiltersRepoImpl repo;

  setUpAll(() => SharedPreferences.setMockInitialValues({}));

  setUp(() {
    api = _FakeApiService();
    network = _FakeNetworkInfo();
    repo = SearchWithFiltersRepoImpl(api, cache, network);
  });

  tearDown(() => cache.clearCache(CacheKeys.searchWithFilters('النصيحة', '', '', '', '', '')));

  test('search maps results and caches them for the same filters', () async {
    final result = await repo.search(_filters);

    final hadith = (result as ApiSuccess<List<ChapterHadith>>).data.single;
    expect(hadith.hadithArabic, 'الدين النصيحة');
    expect(hadith.book?.writerName, 'مسلم');
    expect((await repo.getCachedResults(_filters))?.single.id, 1);
  });

  test('search fails with the offline message without calling the API', () async {
    network.connected = false;

    final result = await repo.search(_filters);

    final failure = (result as ApiFailure).failure;
    expect(failure, isA<NetworkFailure>());
    expect(failure.message, 'لا يوجد اتصال بالإنترنت');
    expect(api.calls, 0);
  });
}
