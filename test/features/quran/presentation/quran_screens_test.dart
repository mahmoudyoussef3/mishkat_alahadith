import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/theming/app_palette.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_scope.dart';
import 'package:mishkat_almasabih/core/theming/app_theme.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_last_read.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/filter_surahs_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_juz_index_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_last_read_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_page_info_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_quran_bookmarks_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_surahs_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/remove_quran_bookmark_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/search_quran_use_case.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_index/quran_index_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_search/quran_search_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/screens/quran_home_screen.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/screens/quran_search_screen.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/screens/tajweed_guide_screen.dart';

import '../quran_fakes.dart';

QuranIndexCubit _cubit(FakeQuranRepo quran, FakeQuranReadingRepo reading) =>
    QuranIndexCubit(
      GetSurahsUseCase(quran),
      GetJuzIndexUseCase(quran),
      FilterSurahsUseCase(),
      GetQuranBookmarksUseCase(reading),
      RemoveQuranBookmarkUseCase(reading),
      GetLastReadUseCase(reading),
      GetPageInfoUseCase(quran),
    );

Widget _app(Widget screen, {required Brightness brightness}) => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder:
      (_, __) => MaterialApp(
        theme:
            brightness == Brightness.dark
                ? AppTheme.darkTheme
                : AppTheme.lightTheme,
        home: AppPaletteScope(child: screen),
      ),
);

/// A phone-sized screen, so lazily built lists show their first rows.
void _usePhoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Loads the index, then shows the Quran home over it.
Future<QuranIndexCubit> _pumpHome(
  WidgetTester tester, {
  FakeQuranReadingRepo? reading,
  Brightness brightness = Brightness.light,
}) async {
  _usePhoneScreen(tester);
  final cubit = _cubit(FakeQuranRepo(), reading ?? FakeQuranReadingRepo());
  await cubit.load();
  await tester.pumpWidget(
    _app(
      BlocProvider.value(value: cubit, child: const QuranHomeScreen()),
      brightness: brightness,
    ),
  );
  await tester.pumpAndSettle();
  return cubit;
}

void main() {
  tearDown(() => ColorsManager.usePalette(AppPalette.light));

  for (final brightness in Brightness.values) {
    testWidgets('the Quran home lays out in ${brightness.name} mode', (
      tester,
    ) async {
      final cubit = await _pumpHome(tester, brightness: brightness);

      expect(tester.takeException(), isNull);
      expect(find.text('القرآن الكريم'), findsOneWidget);
      expect(find.text('البقرة'), findsOneWidget);
      await cubit.close();
    });
  }

  testWidgets('invites a first-time reader to start from Al-Fātiḥah', (
    tester,
  ) async {
    final cubit = await _pumpHome(tester);

    expect(find.text('ابدأ رحلتك مع كتاب الله'), findsOneWidget);
    expect(find.text('سورة الفاتحة'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('screen readers can start reading from the hero card', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final cubit = await _pumpHome(tester);

    final hero = find.bySemanticsLabel('ابدأ القراءة من سورة الفاتحة');
    expect(
      tester.getSemantics(hero),
      isSemantics(isButton: true, hasTapAction: true),
    );
    await cubit.close();
    semantics.dispose();
  });

  testWidgets('shows where the reader stopped and how far through it is', (
    tester,
  ) async {
    final reading = FakeQuranReadingRepo(
      lastRead: QuranLastRead(page: 22, savedAt: DateTime(2026)),
    );
    final cubit = await _pumpHome(tester, reading: reading);

    expect(find.text('تابع من حيث توقفت'), findsOneWidget);
    expect(find.text('سورة البقرة'), findsOneWidget);
    expect(find.text('الجزء الثاني'), findsOneWidget);
    expect(find.text('٣٪ من المصحف'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('switches to the juz index', (tester) async {
    final cubit = await _pumpHome(tester);

    await tester.tap(find.text('الأجزاء'));
    await tester.pumpAndSettle();

    // The fake index has ajzāʾ 1, 2 and 6; the hero names only the first.
    expect(find.text('الجزء السادس'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await cubit.close();
  });

  testWidgets('explains how to save the first bookmark', (tester) async {
    final cubit = await _pumpHome(tester);

    await tester.tap(find.text('العلامات'));
    await tester.pumpAndSettle();

    expect(find.text('لا توجد علامات بعد'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('deleting a bookmark removes its row', (tester) async {
    final reading = FakeQuranReadingRepo(bookmarks: [pageBookmark(30)]);
    final cubit = await _pumpHome(tester, reading: reading);
    await tester.tap(find.text('العلامات'));
    await tester.pumpAndSettle();
    expect(find.text('سورة البقرة'), findsOneWidget);

    await tester.tap(find.byTooltip('حذف العلامة'));
    await tester.pumpAndSettle();

    expect(find.text('لا توجد علامات بعد'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('says so when no surah matches the filter', (tester) async {
    final cubit = await _pumpHome(tester);

    await tester.enterText(find.byType(TextField), 'زمر');
    await tester.pumpAndSettle();

    expect(find.text('لا توجد سورة مطابقة'), findsOneWidget);
    await cubit.close();
  });

  group('search', () {
    Future<QuranSearchCubit> pumpSearch(WidgetTester tester) async {
      _usePhoneScreen(tester);
      final cubit = QuranSearchCubit(
        SearchQuranUseCase(FakeQuranRepo()),
        debounce: Duration.zero,
      );
      await tester.pumpWidget(
        _app(
          BlocProvider.value(value: cubit, child: const QuranSearchScreen()),
          brightness: Brightness.light,
        ),
      );
      await tester.pumpAndSettle();
      return cubit;
    }

    testWidgets('says so when no ayah contains the words', (tester) async {
      final cubit = await pumpSearch(tester);

      await tester.enterText(find.byType(TextField), 'زخرف');
      await tester.pumpAndSettle();

      expect(find.text('لا توجد نتائج'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await cubit.close();
    });

    testWidgets('clearing the field returns to the suggestions at once', (
      tester,
    ) async {
      final cubit = await pumpSearch(tester);
      await tester.enterText(find.byType(TextField), 'زخرف');
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('مسح'));
      await tester.pump();

      expect(cubit.state, isA<QuranSearchIdle>());
      expect(find.text('اكتب كلمة أو جزءًا من آية'), findsOneWidget);
      await cubit.close();
    });
  });

  for (final brightness in Brightness.values) {
    testWidgets('the tajweed guide lays out in ${brightness.name} mode', (
      tester,
    ) async {
      _usePhoneScreen(tester);
      await tester.pumpWidget(
        _app(const TajweedGuideScreen(), brightness: brightness),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('دليل أحكام التجويد'), findsOneWidget);
    });
  }
}
