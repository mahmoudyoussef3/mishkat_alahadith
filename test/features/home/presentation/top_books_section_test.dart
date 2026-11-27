import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/home/presentation/ui/widgets/top_books_section.dart';
import 'package:mishkat_almasabih/features/library/domain/entities/library_statistics.dart';
import 'package:mishkat_almasabih/features/library/domain/repos/library_repo.dart';
import 'package:mishkat_almasabih/features/library/domain/usecases/get_cached_library_statistics_use_case.dart';
import 'package:mishkat_almasabih/features/library/domain/usecases/get_library_statistics_use_case.dart';
import 'package:mishkat_almasabih/features/library/presentation/logic/library_statistics/get_library_statistics_cubit.dart';
import 'package:mishkat_almasabih/features/main_navigation/presentation/logic/main_navigation_cubit.dart';

const _statistics = LibraryStatistics(
  totalBooks: 2,
  totalHadiths: 14840,
  totalChapters: 155,
  booksByCategory: {},
  topBooks: [
    TopBookStatistics(name: 'Sahih Muslim', hadiths: 7564, chapters: 56),
    TopBookStatistics(name: 'Sahih Bukhari', hadiths: 7276, chapters: 99),
  ],
  lastUpdated: '2026-10-04',
);

class _FakeLibraryRepo extends Fake implements LibraryRepo {
  @override
  Future<LibraryStatistics?> getCachedStatistics() async => null;

  @override
  Future<ApiResult<LibraryStatistics>> getStatistics() async =>
      const ApiResult.success(_statistics);
}

void main() {
  for (final scale in [1.0, 1.3]) {
    testWidgets('lays out the shelf without overflow at text scale $scale', (
      tester,
    ) async {
      final repo = _FakeLibraryRepo();
      final statistics = GetLibraryStatisticsCubit(
        GetCachedLibraryStatisticsUseCase(repo),
        GetLibraryStatisticsUseCase(repo),
      );
      await statistics.emitGetStatisticsCubit();
      final navigation = MainNavigationCubit();

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder:
              (_, __) => MaterialApp(
                home: MediaQuery.withClampedTextScaling(
                  minScaleFactor: scale,
                  maxScaleFactor: scale,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: MultiBlocProvider(
                      providers: [
                        BlocProvider.value(value: statistics),
                        BlocProvider.value(value: navigation),
                      ],
                      child: const Scaffold(
                        body: CustomScrollView(slivers: [TopBooksSection()]),
                      ),
                    ),
                  ),
                ),
              ),
        ),
      );

      expect(find.text('صحيح مسلم'), findsOneWidget);
      expect(find.text('٧٥٦٤ حديثاً · ٥٦ باباً'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await statistics.close();
      await navigation.close();
    });
  }

  testWidgets('"عرض الكل" switches to the library tab', (tester) async {
    final repo = _FakeLibraryRepo();
    final statistics = GetLibraryStatisticsCubit(
      GetCachedLibraryStatisticsUseCase(repo),
      GetLibraryStatisticsUseCase(repo),
    );
    await statistics.emitGetStatisticsCubit();
    final navigation = MainNavigationCubit();

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder:
            (_, __) => MaterialApp(
              home: MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: statistics),
                  BlocProvider.value(value: navigation),
                ],
                child: const Scaffold(
                  body: CustomScrollView(slivers: [TopBooksSection()]),
                ),
              ),
            ),
      ),
    );
    await tester.tap(find.text('عرض الكل'));

    expect(navigation.state, MainTab.library);
    await statistics.close();
    await navigation.close();
  });
}
