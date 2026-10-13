import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/tajweed_info.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_flowing_page_use_case.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/flowing_page/flowing_page_cubit.dart';

import '../quran_fakes.dart';

void main() {
  test('starts out loading', () async {
    final cubit = FlowingPageCubit(GetFlowingPageUseCase(FakeQuranRepo()));

    expect(cubit.state, isA<FlowingPageLoading>());
    await cubit.close();
  });

  test('load shows the page grouped by surah', () async {
    final cubit = FlowingPageCubit(GetFlowingPageUseCase(FakeQuranRepo()));

    await cubit.load(106, includeNaturalMadd: false);

    final state = cubit.state as FlowingPageReady;
    expect(state.page.page, 106);
    expect(state.page.sections.map((s) => s.surah), [nisa, maidah]);
    await cubit.close();
  });

  test('load asks for the natural madd when it is on', () async {
    final repo = FakeQuranRepo();
    final cubit = FlowingPageCubit(GetFlowingPageUseCase(repo));

    await cubit.load(1, includeNaturalMadd: true);

    expect(repo.tajweedRequests.first.includeNaturalMadd, isTrue);
    await cubit.close();
  });

  test('load reports a page that cannot be read', () async {
    final cubit = FlowingPageCubit(
      GetFlowingPageUseCase(FakeQuranRepo(failAyahs: true)),
    );

    await cubit.load(1, includeNaturalMadd: false);

    expect(cubit.state, isA<FlowingPageFailure>());
    await cubit.close();
  });

  test('a reload keeps the page shown until the new one is ready', () async {
    final repo = FakeQuranRepo();
    final cubit = FlowingPageCubit(GetFlowingPageUseCase(repo));
    await cubit.load(1, includeNaturalMadd: false);
    final gate = repo.pageGates[1] = Completer<void>();

    final reload = cubit.load(1, includeNaturalMadd: true);

    expect(cubit.state, isA<FlowingPageReady>());
    gate.complete();
    await reload;
    await cubit.close();
  });

  test(
    'an earlier load that finishes last does not replace a later one',
    () async {
      const ghunna = TajweedSegment(start: 0, end: 2, ruleKey: 'ghunna');
      final repo = FakeQuranRepo();
      final cubit = FlowingPageCubit(GetFlowingPageUseCase(repo));
      final gate = repo.pageGates[1] = Completer<void>();
      final earlier = cubit.load(1, includeNaturalMadd: false);
      repo.pageGates.remove(1);
      repo.tajweed = {
        2: const [ghunna],
      };

      await cubit.load(1, includeNaturalMadd: true);
      repo.tajweed = const {};
      gate.complete();
      await earlier;

      final ready = cubit.state as FlowingPageReady;
      expect(ready.page.sections.single.ayahs.last.tajweed, [ghunna]);
      await cubit.close();
    },
  );

  test('a retry after a failure shows the page', () async {
    final repo = FakeQuranRepo(failAyahs: true);
    final cubit = FlowingPageCubit(GetFlowingPageUseCase(repo));
    await cubit.load(1, includeNaturalMadd: false);
    repo.failAyahs = false;

    await cubit.load(1, includeNaturalMadd: false);

    expect(cubit.state, isA<FlowingPageReady>());
    await cubit.close();
  });
}
