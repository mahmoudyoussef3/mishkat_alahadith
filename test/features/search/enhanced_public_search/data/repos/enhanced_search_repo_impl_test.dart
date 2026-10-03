import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/api_service.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/core/networking/network_info.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/data/models/enhanced_search_response_model.dart';
import 'package:mishkat_almasabih/features/search/enhanced_public_search/data/repos/enhanced_search_repo_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeApiService extends Fake implements ApiService {
  Map<String, dynamic>? body;

  @override
  Future<EnhancedSearch> getEnhancedSearch(Map<String, dynamic> body) async {
    this.body = body;
    return EnhancedSearch(
      results: [EnhancedHadithModel(id: '3', hadeethIntro: 'مقدمة', reference: 'رواه مسلم')],
    );
  }
}

class _FakeNetworkInfo implements NetworkInfo {
  bool connected = true;

  @override
  Future<bool> get isConnected async => connected;
}

void main() {
  final cache = GenericCacheService.instance;
  late _FakeApiService api;
  late _FakeNetworkInfo network;
  late EnhancedSearchRepoImpl repo;

  setUpAll(() => SharedPreferences.setMockInitialValues({}));

  setUp(() {
    api = _FakeApiService();
    network = _FakeNetworkInfo();
    repo = EnhancedSearchRepoImpl(api, cache, network);
  });

  tearDown(() => cache.clearCache(CacheKeys.enhancedSearch('الصبر')));

  test('search sends the term, maps and caches the results', () async {
    final result = await repo.search('الصبر');

    expect(api.body, {'searchTerm': 'الصبر'});
    final hadith = (result as ApiSuccess<List<ExplainedHadith>>).data.single;
    expect(hadith.reference, 'رواه مسلم');
    expect((await repo.getCachedResults('الصبر'))?.single.hadeethIntro, 'مقدمة');
  });

  test('search fails fast offline', () async {
    network.connected = false;

    final result = await repo.search('الصبر');

    expect((result as ApiFailure).failure, isA<NetworkFailure>());
    expect(api.body, isNull);
  });
}
