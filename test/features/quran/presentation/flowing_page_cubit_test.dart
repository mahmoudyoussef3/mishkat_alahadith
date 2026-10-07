import 'package:flutter_test/flutter_test.dart';
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
