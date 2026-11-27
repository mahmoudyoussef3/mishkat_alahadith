import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_category.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/zikr.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/search_azkar_use_case.dart';

import '../azkar_fakes.dart';

void main() {
  late SearchAzkarUseCase search;

  setUp(() => search = SearchAzkarUseCase());

  test('a query shorter than two letters cannot be searched', () {
    expect(search.canSearch('س'), isFalse);
    expect(search(sampleCatalog, 'س').isEmpty, isTrue);
  });

  test('finds a zikr whatever its harakat', () {
    final results = search(sampleCatalog, 'سبحان الله');

    expect(results.hits.single.zikr.id, 2);
    expect(results.hits.single.category.id, 27);
  });

  test('finds a zikr typed with a plain alef for a hamza', () {
    final results = search(sampleCatalog, 'اعوذ بالله');

    expect(results.hits.single.zikr.id, 1);
  });

  test('matches chapter titles', () {
    final results = search(sampleCatalog, 'النوم');

    expect(results.categories.single.id, 28);
  });

  test('finds a zikr by its translation, ignoring case', () {
    final results = search(sampleCatalogEnglish, 'MEANING 96');

    expect(results.hits.single.category.id, 96);
  });

  test('a query never matches across two fields of one entry', () {
    // «…لله» ends the Arabic and «Meaning» starts the translation.
    final results = search(sampleCatalogEnglish, 'وأحيا Meaning');

    expect(results.isEmpty, isTrue);
  });

  test('stops listing hits at the limit but counts them all', () {
    final catalog = [
      AzkarCategory(
        id: 1,
        title: 'ذكر',
        azkar: [
          for (var i = 1; i <= SearchAzkarUseCase.maxHits + 5; i++)
            Zikr(id: i, text: 'سبحان الله $i', count: 1),
        ],
      ),
    ];

    final results = search(catalog, 'سبحان');

    expect(results.hits, hasLength(SearchAzkarUseCase.maxHits));
    expect(results.totalHits, SearchAzkarUseCase.maxHits + 5);
    expect(results.isTruncated, isTrue);
  });

  test('rebuilds its index for a new catalogue', () {
    search(sampleCatalog, 'Meaning');

    expect(search(sampleCatalogEnglish, 'Meaning').hits, isNotEmpty);
  });
}
