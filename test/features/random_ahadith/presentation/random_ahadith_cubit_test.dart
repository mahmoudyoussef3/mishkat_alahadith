import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/random_ahadith/domain/repos/random_ahadith_repo.dart';
import 'package:mishkat_almasabih/features/random_ahadith/domain/usecases/get_random_ahadith_use_case.dart';
import 'package:mishkat_almasabih/features/random_ahadith/presentation/logic/random_ahadith_cubit.dart';

const _first = [ExplainedHadith(id: '1', hadeeth: 'الأول')];
const _second = [ExplainedHadith(id: '2', hadeeth: 'الثاني')];

/// Holds each request until the test answers it.
class _ScriptedRepo extends Fake implements RandomAhadithRepo {
  final requests = <Completer<ApiResult<List<ExplainedHadith>>>>[];

  @override
  Future<ApiResult<List<ExplainedHadith>>> getRandomAhadith() {
    final request = Completer<ApiResult<List<ExplainedHadith>>>();
    requests.add(request);
    return request.future;
  }
}

void main() {
  late _ScriptedRepo repo;
  late RandomAhadithCubit cubit;

  setUp(() {
    repo = _ScriptedRepo();
    cubit = RandomAhadithCubit(GetRandomAhadithUseCase(repo));
  });

  tearDown(() => cubit.close());

  /// Loads [_first], then starts a refresh and leaves it pending.
  Future<void> startRefresh() async {
    final load = cubit.emitRandomStats();
    repo.requests.single.complete(const ApiResult.success(_first));
    await load;
    unawaited(cubit.emitRandomStats());
  }

  test('reports a failure when nothing has loaded yet', () async {
    final load = cubit.emitRandomStats();
    repo.requests.single.complete(const ApiResult.failure(NetworkFailure()));
    await load;

    expect(
      cubit.state,
      isA<RandomAhaditFailure>().having(
        (state) => state.errMessage,
        'errMessage',
        FailureMessages.noConnection,
      ),
    );
  });

  test(
    'marks the shown hadiths as refreshing instead of dropping them',
    () async {
      await startRefresh();

      expect(
        cubit.state,
        isA<RandomAhadithSuccess>()
            .having((state) => state.hadiths, 'hadiths', same(_first))
            .having((state) => state.refreshing, 'refreshing', isTrue),
      );
    },
  );

  test('shows the new hadiths once the refresh succeeds', () async {
    await startRefresh();
    repo.requests.last.complete(const ApiResult.success(_second));
    await pumpEventQueue();

    expect(
      cubit.state,
      isA<RandomAhadithSuccess>()
          .having((state) => state.hadiths, 'hadiths', same(_second))
          .having((state) => state.refreshing, 'refreshing', isFalse),
    );
  });

  test('keeps the shown hadiths when the refresh fails', () async {
    await startRefresh();
    repo.requests.last.complete(const ApiResult.failure(NetworkFailure()));
    await pumpEventQueue();

    expect(
      cubit.state,
      isA<RandomAhadithSuccess>()
          .having((state) => state.hadiths, 'hadiths', same(_first))
          .having((state) => state.refreshing, 'refreshing', isFalse)
          .having(
            (state) => state.refreshFailure,
            'refreshFailure',
            FailureMessages.noConnection,
          ),
    );
  });

  test(
    'joins a refresh already under way instead of requesting again',
    () async {
      await startRefresh();
      unawaited(cubit.emitRandomStats());

      expect(repo.requests, hasLength(2));
    },
  );
}
