import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/hadith_details/presentation/logic/hadith_reader_cubit.dart';
import 'package:mishkat_almasabih/features/navigation/domain/entities/hadith_navigation.dart';
import 'package:mishkat_almasabih/features/navigation/domain/repos/navigation_repo.dart';
import 'package:mishkat_almasabih/features/navigation/domain/usecases/get_cached_hadith_navigation_use_case.dart';
import 'package:mishkat_almasabih/features/navigation/domain/usecases/get_hadith_navigation_use_case.dart';
import 'package:mishkat_almasabih/features/navigation/domain/usecases/get_local_hadith_navigation_use_case.dart';

/// A chapter of hadiths 8, 9 and 10.
class _ChapterRepo implements NavigationRepo {
  bool fail = false;
  Completer<void>? hold;
  final remoteCalls = <String>[];
  final localCalls = <String>[];

  static HadithNavigation _around(String id) => switch (id) {
    '8' => const HadithNavigation(
      nextHadith: NavigationHadithRef(id: '9', title: 'نص ٩'),
      totalHadiths: 3,
    ),
    '9' => const HadithNavigation(
      prevHadith: NavigationHadithRef(id: '8', title: 'نص ٨'),
      nextHadith: NavigationHadithRef(id: '10', title: 'نص ١٠'),
      totalHadiths: 3,
    ),
    _ => const HadithNavigation(
      prevHadith: NavigationHadithRef(id: '9', title: 'نص ٩'),
      totalHadiths: 3,
    ),
  };

  @override
  Future<HadithNavigation?> getCachedNavigation({
    required String hadithNumber,
    required String bookSlug,
    required String chapterNumber,
  }) async => null;

  @override
  Future<ApiResult<HadithNavigation>> getNavigation({
    required String hadithNumber,
    required String bookSlug,
    required String chapterNumber,
  }) async {
    remoteCalls.add(hadithNumber);
    await hold?.future;
    if (fail) return const ApiResult.failure(NetworkFailure());
    return ApiResult.success(_around(hadithNumber));
  }

  @override
  Future<ApiResult<HadithNavigation>> getLocalNavigation({
    required String hadithNumber,
    required String bookSlug,
  }) async {
    localCalls.add(hadithNumber);
    return ApiResult.success(_around(hadithNumber));
  }
}

void main() {
  late _ChapterRepo repo;
  late HadithReaderCubit cubit;

  setUp(() {
    repo = _ChapterRepo();
    cubit = HadithReaderCubit(
      GetCachedHadithNavigationUseCase(repo),
      GetHadithNavigationUseCase(repo),
      GetLocalHadithNavigationUseCase(repo),
    );
  });

  tearDown(() => cubit.close());

  Future<void> startAt(String id, {bool isLocal = false}) => cubit.start(
    hadithId: id,
    text: 'نص $id',
    bookSlug: 'sahih-bukhari',
    chapterNumber: '2',
    isLocal: isLocal,
  );

  test('start finds both neighbours and the chapter size', () async {
    await startAt('9');

    expect(cubit.state.hasPrevious, isTrue);
    expect(cubit.state.hasNext, isTrue);
    expect(cubit.state.chapterTotal, 3);
    expect(cubit.state.isLoading, isFalse);
  });

  test('next shows the following hadith and its own neighbours', () async {
    await startAt('9');

    await cubit.next();

    expect(cubit.state.hadithId, '10');
    expect(cubit.state.text, 'نص ١٠');
    expect(cubit.state.hasNext, isFalse);
    expect(cubit.state.previous?.id, '9');
  });

  test('previous is unavailable at the first hadith', () async {
    await startAt('8');

    await cubit.previous();

    expect(cubit.state.hadithId, '8');
    expect(cubit.state.hasPrevious, isFalse);
  });

  test('ignores steps while neighbours are still loading', () async {
    repo.hold = Completer();
    final starting = startAt('9');

    await cubit.next();
    repo.hold!.complete();
    await starting;

    expect(cubit.state.hadithId, '9');
  });

  test('marks a failure and recovers on retry', () async {
    repo.fail = true;
    await startAt('9');
    expect(cubit.state.failed, isTrue);
    expect(cubit.state.hasNext, isFalse);

    repo.fail = false;
    await cubit.retry();

    expect(cubit.state.failed, isFalse);
    expect(cubit.state.hasNext, isTrue);
  });

  test('local books use the local navigation', () async {
    await startAt('9', isLocal: true);

    expect(repo.localCalls, ['9']);
    expect(repo.remoteCalls, isEmpty);
  });

  test('does not look up neighbours when navigation is off', () async {
    await cubit.start(
      hadithId: '9',
      text: 'نص ٩',
      bookSlug: 'sahih-bukhari',
      chapterNumber: '2',
      isLocal: false,
      withNavigation: false,
    );

    expect(repo.remoteCalls, isEmpty);
    expect(cubit.state.isLoading, isFalse);
  });

  group('nextWhenReady', () {
    test('steps at once when the neighbours are known', () async {
      await startAt('9');

      await cubit.nextWhenReady();

      expect(cubit.state.hadithId, '10');
    });

    test('steps once the neighbours finish loading', () async {
      repo.hold = Completer();
      final starting = startAt('9');

      await cubit.nextWhenReady();
      expect(cubit.state.hadithId, '9');
      repo.hold!.complete();
      await starting;
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.hadithId, '10');
    });

    test('stays when the neighbours fail to load', () async {
      repo.hold = Completer();
      repo.fail = true;
      final starting = startAt('9');

      await cubit.nextWhenReady();
      repo.hold!.complete();
      await starting;

      expect(cubit.state.hadithId, '9');
      expect(cubit.state.failed, isTrue);
    });
  });
}
