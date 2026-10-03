import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/networking/caching_helper.dart';
import 'package:mishkat_almasabih/core/data/datasources/hadeethenc_datasource.dart';
import 'package:mishkat_almasabih/core/networking/network_info.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/data/datasources/categories_datasource.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/data/models/category_model.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/data/models/hadith_by_category_model.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/data/repos/categories_repository_impl.dart';
import 'package:mishkat_almasabih/features/ahadith_categories/domain/entities/category_entity.dart';
import 'package:mishkat_almasabih/core/data/models/new_daily_hadith_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeDatasource implements CategoriesDatasource {
  Object? error;

  @override
  Future<List<CategoryModel>> getCategories() async {
    if (error != null) throw error!;
    return [CategoryModel.fromJson({'id': '1', 'title': 'العقيدة', 'hadeeths_count': '12'})];
  }

  @override
  Future<HadithByCategoryResponseModel> getAhadithByCategory(
    String categoryId, {
    int? page,
    int? perPage,
  }) async => throw UnimplementedError();
}

class _FakeHadeethEnc implements HadeethEncDataSource {
  int calls = 0;

  @override
  Future<NewDailyHadithModel> fetchHadith(String id) async {
    calls++;
    return NewDailyHadithModel(id: id, explanation: 'شرح');
  }
}

class _FakeNetworkInfo implements NetworkInfo {
  bool connected = true;

  @override
  Future<bool> get isConnected async => connected;
}

void main() {
  final cache = GenericCacheService.instance;
  late _FakeDatasource datasource;
  late _FakeHadeethEnc hadeethEnc;
  late _FakeNetworkInfo network;
  late CategoriesRepositoryImpl repo;

  setUpAll(() => SharedPreferences.setMockInitialValues({}));

  setUp(() {
    datasource = _FakeDatasource();
    hadeethEnc = _FakeHadeethEnc();
    network = _FakeNetworkInfo();
    repo = CategoriesRepositoryImpl(datasource, hadeethEnc, cache, network);
  });

  tearDown(() async {
    await cache.clearCache(CacheKeys.hadithCategories);
    await cache.clearCache(CacheKeys.hadithDetails('7'));
  });

  test('getCategories maps models to entities', () async {
    final result = await repo.getCategories();

    final category = (result as ApiSuccess<List<CategoryEntity>>).data.single;
    expect(category.title, 'العقيدة');
  });

  test('getCategories returns a typed failure instead of the raw exception text', () async {
    datasource.error = Exception('boom');

    final result = await repo.getCategories();

    final failure = (result as ApiFailure).failure;
    expect(failure, isA<UnexpectedFailure>());
    expect(failure.message, isNot(contains('boom')));
  });

  test('getHadithDetails fetches, caches and maps the explained hadith', () async {
    final result = await repo.getHadithDetails('7');

    expect((result as ApiSuccess<ExplainedHadith>).data.explanation, 'شرح');
    expect((await repo.getCachedHadithDetails('7'))?.id, '7');
  });

  test('getHadithDetails fails fast offline without calling HadeethEnc', () async {
    network.connected = false;

    final result = await repo.getHadithDetails('7');

    expect((result as ApiFailure).failure, isA<NetworkFailure>());
    expect(hadeethEnc.calls, 0);
  });
}
