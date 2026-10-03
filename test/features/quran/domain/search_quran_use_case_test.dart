import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_ayah.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/search_quran_use_case.dart';

import '../quran_fakes.dart';

void main() {
  test('a query shorter than two letters returns no hits', () async {
    final search = SearchQuranUseCase(FakeQuranRepo());

    final results = dataOf(await search('ب'));

    expect(results.hits, isEmpty);
    expect(results.totalMatches, 0);
  });

  test('finds an ayah typed without harakat or Uthmanic spelling', () async {
    final search = SearchQuranUseCase(FakeQuranRepo());

    final results = dataOf(await search('الرحمن'));

    expect(results.hits.map((h) => h.ayah), [basmalah]);
    expect(results.hits.single.surahName, 'الفاتحة');
  });

  test('marks where the query sits in the original text', () async {
    final search = SearchQuranUseCase(FakeQuranRepo());

    final hit = dataOf(await search('الرحمن')).hits.single;
    final match = hit.matches.single;

    expect(basmalah.text.substring(match.start, match.end), 'ٱلرَّحۡمَٰنِ');
  });

  test('marks every occurrence within one ayah', () async {
    const repeated = QuranAyah(
      id: 50,
      surahNumber: 2,
      number: 43,
      juz: 1,
      page: 7,
      text: 'ٱللَّهُ لَآ إِلَٰهَ إِلَّا ٱللَّهُ',
    );
    final search = SearchQuranUseCase(FakeQuranRepo(ayahs: [repeated]));

    final hit = dataOf(await search('الله')).hits.single;

    expect(hit.matches, hasLength(2));
  });

  test('caps the hits but still counts every matching ayah', () async {
    final many = [
      for (var i = 1; i <= SearchQuranUseCase.maxHits + 50; i++)
        QuranAyah(
          id: i,
          surahNumber: 2,
          number: i,
          juz: 1,
          page: 2,
          text: 'قُلۡ هُوَ',
        ),
    ];
    final search = SearchQuranUseCase(FakeQuranRepo(ayahs: many));

    final results = dataOf(await search('قل'));

    expect(results.hits, hasLength(SearchQuranUseCase.maxHits));
    expect(results.totalMatches, SearchQuranUseCase.maxHits + 50);
    expect(results.isTruncated, isTrue);
  });

  test('builds the search index only once', () async {
    final repo = FakeQuranRepo();
    final search = SearchQuranUseCase(repo);

    await search('الرحمن');
    await search('الحمد');

    expect(repo.allAyahsCalls, 1);
  });

  test('queries typed during the first build share it', () async {
    final repo = FakeQuranRepo();
    final search = SearchQuranUseCase(repo);

    await Future.wait([search('الرحمن'), search('الحمد'), search('رب')]);

    expect(repo.allAyahsCalls, 1);
  });

  test('a failed build is retried by the next query', () async {
    final repo = FakeQuranRepo(failAyahs: true);
    final search = SearchQuranUseCase(repo);
    await search('الرحمن');
    repo.failAyahs = false;

    final results = dataOf(await search('الرحمن'));

    expect(results.hits, isNotEmpty);
  });

  test('fails when the text cannot be loaded', () async {
    final search = SearchQuranUseCase(FakeQuranRepo(failAyahs: true));

    expect(await search('الرحمن'), isA<ApiFailure>());
  });

  test('canSearch needs at least two letters after folding', () {
    final search = SearchQuranUseCase(FakeQuranRepo());

    expect(search.canSearch('بِ'), isFalse);
    expect(search.canSearch('رب'), isTrue);
  });
}
