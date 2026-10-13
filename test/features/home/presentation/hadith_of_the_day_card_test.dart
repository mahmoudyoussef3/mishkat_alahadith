import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/domain/entities/explained_hadith.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/features/hadith_daily/domain/repos/daily_hadith_repo.dart';
import 'package:mishkat_almasabih/features/hadith_daily/domain/usecases/fetch_daily_hadith_use_case.dart';
import 'package:mishkat_almasabih/features/hadith_daily/domain/usecases/get_saved_daily_hadith_use_case.dart';
import 'package:mishkat_almasabih/features/hadith_daily/presentation/logic/daily_hadith_cubit.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/daily_hadith_card.dart';

const _bareQuote = ExplainedHadith(
  id: '65060',
  hadeeth: '"الكلمة الطيبة صدقة، وكل خطوة تمشيها إلى الصلاة صدقة"',
  attribution: 'رواه البخاري 2989',
  grade: 'صحيح',
);

class _FakeDailyHadithRepo extends Fake implements DailyHadithRepo {
  _FakeDailyHadithRepo(this.saved);

  final ExplainedHadith? saved;

  @override
  Future<ExplainedHadith?> getSavedHadith() async => saved;

  @override
  Future<ApiResult<ExplainedHadith>> fetchAndSaveHadith(String id) async =>
      const ApiResult.failure(NetworkFailure());
}

DailyHadithCubit _cubit(ExplainedHadith? saved) {
  final repo = _FakeDailyHadithRepo(saved);
  return DailyHadithCubit(
    GetSavedDailyHadithUseCase(repo),
    FetchDailyHadithUseCase(repo),
  );
}

Future<void> _pumpCard(
  WidgetTester tester,
  DailyHadithCubit cubit, {
  double textScale = 1,
  RouteFactory? onGenerateRoute,
}) async {
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder:
          (_, __) => MaterialApp(
            onGenerateRoute: onGenerateRoute,
            home: MediaQuery.withClampedTextScaling(
              minScaleFactor: textScale,
              maxScaleFactor: textScale,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: BlocProvider.value(
                  value: cubit,
                  child: const Scaffold(
                    body: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: HadithOfTheDayCard(),
                    ),
                  ),
                ),
              ),
            ),
          ),
    ),
  );
  // Runs the post-frame load, then rebuilds with its result.
  await tester.pump();
  await tester.pump();
}

void main() {
  for (final scale in [1.0, 1.3]) {
    testWidgets('lays out the framed hadith without overflow at text scale '
        '$scale', (tester) async {
      final cubit = _cubit(_bareQuote);
      await _pumpCard(tester, cubit, textScale: scale);

      expect(find.text('حديث اليوم'), findsOneWidget);
      expect(
        find.text('«الكلمة الطيبة صدقة، وكل خطوة تمشيها إلى الصلاة صدقة»'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      await cubit.close();
    });
  }

  testWidgets('shows the source in Arabic digits beside its grade', (
    tester,
  ) async {
    final cubit = _cubit(_bareQuote);
    await _pumpCard(tester, cubit);

    expect(find.text('رواه البخاري ٢٩٨٩'), findsOneWidget);
    expect(find.text('صحيح'), findsOneWidget);

    await cubit.close();
  });

  testWidgets('does not attribute the text to a speaker on its own', (
    tester,
  ) async {
    // Whether the words are the Prophet's ﷺ is not in the data, so the
    // card never adds "قال رسول الله ﷺ" above them.
    final cubit = _cubit(_bareQuote);
    await _pumpCard(tester, cubit);

    expect(find.textContaining('رسول الله'), findsNothing);

    await cubit.close();
  });

  testWidgets('opens the hadith with its explanation from "الشرح"', (
    tester,
  ) async {
    final cubit = _cubit(_bareQuote);
    RouteSettings? opened;
    await _pumpCard(
      tester,
      cubit,
      onGenerateRoute: (settings) {
        opened = settings;
        return MaterialPageRoute(builder: (_) => const SizedBox());
      },
    );

    await tester.ensureVisible(find.text('الشرح'));
    await tester.tap(find.text('الشرح'));
    await tester.pump();

    expect(opened?.name, Routes.hadithOfTheDay);
    expect(opened?.arguments, same(_bareQuote));

    await cubit.close();
  });

  testWidgets('offers a retry when the hadith cannot be loaded', (
    tester,
  ) async {
    final cubit = _cubit(null);
    await _pumpCard(tester, cubit);

    expect(find.text('تعذر تحميل حديث اليوم'), findsOneWidget);
    expect(find.text('إعادة المحاولة'), findsOneWidget);

    await cubit.close();
  });
}
