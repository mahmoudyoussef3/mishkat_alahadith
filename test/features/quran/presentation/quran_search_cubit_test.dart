import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_search_results.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/search_quran_use_case.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_search/quran_search_cubit.dart';

import '../quran_fakes.dart';

/// Answers each query only when the test says so, in any order.
class _ControlledSearch extends SearchQuranUseCase {
  final _pending = <String, Completer<ApiResult<QuranSearchResults>>>{};

  _ControlledSearch() : super(FakeQuranRepo());

  @override
  Future<ApiResult<QuranSearchResults>> call(String query) =>
      (_pending[query] = Completer()).future;

  void answer(String query) => _pending[query]!.complete(
    ApiResult.success(
      QuranSearchResults(
        query: query,
        hits: [
          QuranSearchHit(ayah: hamd, surahName: 'الفاتحة', matches: const []),
        ],
        totalMatches: 1,
      ),
    ),
  );
}

void main() {
  test('a query too short to search leaves the screen idle', () async {
    final cubit = QuranSearchCubit(SearchQuranUseCase(FakeQuranRepo()));

    await cubit.search('ب');

    expect(cubit.state, isA<QuranSearchIdle>());
    await cubit.close();
  });

  test('a matching query shows its hits', () async {
    final cubit = QuranSearchCubit(SearchQuranUseCase(FakeQuranRepo()));

    await cubit.search('الحمد');

    final state = cubit.state as QuranSearchSuccess;
    expect(state.results.hits.single.ayah, hamd);
    await cubit.close();
  });

  test('a query with no matches says so', () async {
    final cubit = QuranSearchCubit(SearchQuranUseCase(FakeQuranRepo()));

    await cubit.search('الكهف');

    expect(cubit.state, isA<QuranSearchEmpty>());
    await cubit.close();
  });

  test('a text that cannot be loaded shows a failure', () async {
    final cubit = QuranSearchCubit(
      SearchQuranUseCase(FakeQuranRepo(failAyahs: true)),
    );

    await cubit.search('الحمد');

    expect(cubit.state, isA<QuranSearchFailure>());
    await cubit.close();
  });

  test('results of an older query never replace a newer one', () async {
    final search = _ControlledSearch();
    final cubit = QuranSearchCubit(search);

    final older = cubit.search('الرحمن');
    final newer = cubit.search('الحمد');
    search.answer('الحمد');
    await newer;
    search.answer('الرحمن');
    await older;

    final state = cubit.state as QuranSearchSuccess;
    expect(state.results.query, 'الحمد');
    await cubit.close();
  });

  test('typing searches once, for the last query, after the pause', () async {
    final repo = FakeQuranRepo();
    final cubit = QuranSearchCubit(
      SearchQuranUseCase(repo),
      debounce: Duration.zero,
    );

    cubit
      ..onQueryChanged('ال')
      ..onQueryChanged('الحم')
      ..onQueryChanged('الحمد');
    await pumpEventQueue();

    final state = cubit.state as QuranSearchSuccess;
    expect(state.results.query, 'الحمد');
    expect(repo.allAyahsCalls, 1);
    await cubit.close();
  });

  test('clear returns to idle', () async {
    final cubit = QuranSearchCubit(SearchQuranUseCase(FakeQuranRepo()));
    await cubit.search('الحمد');

    cubit.clear();

    expect(cubit.state, isA<QuranSearchIdle>());
    await cubit.close();
  });
}
