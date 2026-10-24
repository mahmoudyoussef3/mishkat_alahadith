import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/random_ahadith/domain/repos/random_ahadith_repo.dart';
import 'package:mishkat_almasabih/features/random_ahadith/domain/usecases/get_random_ahadith_use_case.dart';
import 'package:mishkat_almasabih/features/random_ahadith/presentation/logic/random_ahadith_cubit.dart';
import 'package:mishkat_almasabih/features/random_ahadith/presentation/ui/widgets/compact_hadith_tile.dart';
import 'package:mishkat_almasabih/features/random_ahadith/presentation/ui/widgets/random_ahadith_bloc_builder.dart';
import 'package:shimmer/shimmer.dart';

const _hadiths = [
  ExplainedHadith(
    id: '1',
    hadeeth:
        'عن ابن عباس رضي الله عنهما قال: قال لي رسول الله ﷺ: '
        '"القط لي حصى" فلقطت له سبع حصيات هن حصى الخذف',
    attribution: 'رواه النسائي 3057',
    reference: 'سنن النسائي (5/ 268) (3057)، دار الكتب العلمية، بيروت',
    grade: 'صحيح',
    categories: ['مسائل الجاهلية'],
  ),
  ExplainedHadith(
    id: '2',
    hadeeth: '"لا تتخذوا قبري عيدا، وصلوا علي فإن تسليمكم يبلغني أين كنتم"',
    reference: 'كتاب التوحيد',
    grade: 'حسن',
    categories: ['فضائل التوحيد'],
  ),
];

class _FakeRandomAhadithRepo extends Fake implements RandomAhadithRepo {
  _FakeRandomAhadithRepo(this.result);

  final ApiResult<List<ExplainedHadith>> result;

  @override
  Future<ApiResult<List<ExplainedHadith>>> getRandomAhadith() async => result;
}

/// Answers the first request with [_hadiths] and holds every later one
/// until [refresh] completes.
class _HeldRefreshRepo extends Fake implements RandomAhadithRepo {
  final refresh = Completer<ApiResult<List<ExplainedHadith>>>();
  var _requests = 0;

  @override
  Future<ApiResult<List<ExplainedHadith>>> getRandomAhadith() =>
      _requests++ == 0
          ? Future.value(const ApiResult.success(_hadiths))
          : refresh.future;
}

const _firstPreview = '«القط لي حصى» فلقطت له سبع حصيات هن حصى الخذف';

Future<RandomAhadithCubit> _loadedCubit(
  ApiResult<List<ExplainedHadith>> result,
) async {
  final cubit = RandomAhadithCubit(
    GetRandomAhadithUseCase(_FakeRandomAhadithRepo(result)),
  );
  await cubit.emitRandomStats();
  return cubit;
}

Future<void> _pumpSection(
  WidgetTester tester,
  RandomAhadithCubit cubit, {
  double textScale = 1,
}) => tester.pumpWidget(
  ScreenUtilInit(
    designSize: const Size(375, 812),
    builder:
        (_, __) => MaterialApp(
          home: MediaQuery.withClampedTextScaling(
            minScaleFactor: textScale,
            maxScaleFactor: textScale,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: BlocProvider.value(
                value: cubit,
                child: const Scaffold(
                  body: CustomScrollView(slivers: [RandomAhadithBlocBuilder()]),
                ),
              ),
            ),
          ),
        ),
  ),
);

void main() {
  for (final scale in [1.0, 1.3]) {
    testWidgets('lays out one card per hadith without overflow at text '
        'scale $scale', (tester) async {
      final cubit = await _loadedCubit(const ApiResult.success(_hadiths));
      await _pumpSection(tester, cubit, textScale: scale);

      expect(find.text('أحاديث متنوعة'), findsOneWidget);
      expect(find.byType(CompactHadithTile), findsNWidgets(2));
      expect(tester.takeException(), isNull);

      await cubit.close();
    });
  }

  testWidgets('previews the quoted words without the chain of narrators', (
    tester,
  ) async {
    final cubit = await _loadedCubit(const ApiResult.success(_hadiths));
    await _pumpSection(tester, cubit);

    expect(find.text(_firstPreview), findsOneWidget);

    await cubit.close();
  });

  testWidgets('badges each hadith with its topic and grade', (tester) async {
    final cubit = await _loadedCubit(const ApiResult.success(_hadiths));
    await _pumpSection(tester, cubit);

    expect(find.text('مسائل الجاهلية'), findsOneWidget);
    expect(find.text('صحيح'), findsOneWidget);
    expect(find.text('فضائل التوحيد'), findsOneWidget);
    expect(find.text('حسن'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('shows the attribution in Arabic digits', (tester) async {
    final cubit = await _loadedCubit(const ApiResult.success(_hadiths));
    await _pumpSection(tester, cubit);

    expect(find.text('رواه النسائي ٣٠٥٧'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('falls back to the reference when there is no attribution', (
    tester,
  ) async {
    final cubit = await _loadedCubit(const ApiResult.success(_hadiths));
    await _pumpSection(tester, cubit);

    expect(find.text('كتاب التوحيد'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('says the text is unavailable instead of leaving a blank row', (
    tester,
  ) async {
    final cubit = await _loadedCubit(
      const ApiResult.success([ExplainedHadith(id: '3', grade: 'صحيح')]),
    );
    await _pumpSection(tester, cubit);

    expect(find.text('نص الحديث غير متوفر'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('offers a retry when the hadiths cannot be loaded', (
    tester,
  ) async {
    final cubit = await _loadedCubit(const ApiResult.failure(NetworkFailure()));
    await _pumpSection(tester, cubit);

    expect(find.text('إعادة المحاولة'), findsOneWidget);

    await cubit.close();
  });

  group('while refreshing', () {
    // Built inside each test, not in setUp, so the held request resolves in
    // the test's fake-async zone.
    Future<(RandomAhadithCubit, _HeldRefreshRepo)> startRefresh(
      WidgetTester tester,
    ) async {
      final repo = _HeldRefreshRepo();
      final cubit = RandomAhadithCubit(GetRandomAhadithUseCase(repo));
      await cubit.emitRandomStats();
      await _pumpSection(tester, cubit);
      await tester.tap(find.text('تحديث'));
      await tester.pump();
      return (cubit, repo);
    }

    testWidgets('keeps the current hadiths on screen', (tester) async {
      final (cubit, _) = await startRefresh(tester);
      // Past any cross-fade, so a list on its way out would be gone.
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Shimmer), findsNothing);
      expect(find.text(_firstPreview), findsOneWidget);

      await cubit.close();
    });

    testWidgets('keeps the hadiths and says why when the refresh fails', (
      tester,
    ) async {
      final (cubit, repo) = await startRefresh(tester);

      repo.refresh.complete(const ApiResult.failure(NetworkFailure()));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text(_firstPreview), findsOneWidget);
      expect(find.text(FailureMessages.noConnection), findsOneWidget);

      await cubit.close();
    });

    testWidgets('shows progress in place of the refresh icon', (tester) async {
      final (cubit, _) = await startRefresh(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsNothing);

      await cubit.close();
    });

    testWidgets('replaces the hadiths once the new ones arrive', (
      tester,
    ) async {
      final (cubit, repo) = await startRefresh(tester);

      repo.refresh.complete(
        const ApiResult.success([
          ExplainedHadith(id: '9', hadeeth: '"إنما الأعمال بالنيات"'),
        ]),
      );
      await tester.pumpAndSettle();

      expect(find.text('«إنما الأعمال بالنيات»'), findsOneWidget);
      expect(find.text(_firstPreview), findsNothing);

      await cubit.close();
    });
  });
}
