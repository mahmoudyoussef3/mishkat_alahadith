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
import 'package:mishkat_almasabih/features/random_ahadith/presentation/ui/widgets/random_ahadith_bloc_builder.dart';

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
    testWidgets('lays out the grouped rows without overflow at text scale '
        '$scale', (tester) async {
      final cubit = await _loadedCubit(const ApiResult.success(_hadiths));
      await _pumpSection(tester, cubit, textScale: scale);

      expect(find.text('أحاديث متنوعة'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
      expect(tester.takeException(), isNull);

      await cubit.close();
    });
  }

  testWidgets('previews the quoted words without the chain of narrators', (
    tester,
  ) async {
    final cubit = await _loadedCubit(const ApiResult.success(_hadiths));
    await _pumpSection(tester, cubit);

    expect(
      find.text('«القط لي حصى» فلقطت له سبع حصيات هن حصى الخذف'),
      findsOneWidget,
    );

    await cubit.close();
  });

  testWidgets('lists topic, grade and attribution in Arabic digits', (
    tester,
  ) async {
    final cubit = await _loadedCubit(const ApiResult.success(_hadiths));
    await _pumpSection(tester, cubit);

    expect(
      find.text('مسائل الجاهلية  ·  صحيح  ·  رواه النسائي ٣٠٥٧'),
      findsOneWidget,
    );

    await cubit.close();
  });

  testWidgets('falls back to the reference when there is no attribution', (
    tester,
  ) async {
    final cubit = await _loadedCubit(const ApiResult.success(_hadiths));
    await _pumpSection(tester, cubit);

    expect(find.text('فضائل التوحيد  ·  حسن  ·  كتاب التوحيد'), findsOneWidget);

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
}
