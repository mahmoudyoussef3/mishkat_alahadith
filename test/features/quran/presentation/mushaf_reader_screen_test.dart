import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/theming/app_palette.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_override.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_scope.dart';
import 'package:mishkat_almasabih/core/theming/app_theme.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/core/theming/mushaf_palette.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/mushaf_reader_settings.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/tajweed_info.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_mushaf_settings_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_page_info_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_page_tajweed_counts_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_quran_bookmarks_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_surahs_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/save_last_read_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/save_mushaf_settings_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/toggle_quran_bookmark_use_case.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/screens/mushaf_reader_screen.dart';

import '../quran_fakes.dart';

/// The reader on page 1, in a light app, with [settings] saved.
///
/// Only the reader's chrome is checked: the page itself loads the mushaf's
/// text from the package's assets, which these tests leave pending.
Future<MushafReaderCubit> _pumpReader(
  WidgetTester tester, {
  MushafReaderSettings settings = MushafReaderSettings.defaults,
  Map<int, List<TajweedRuleCount>> pageCounts = const {},
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final quran = FakeQuranRepo(pageCounts: pageCounts);
  final reading = FakeQuranReadingRepo(settings: settings);
  final cubit = MushafReaderCubit(
    GetMushafSettingsUseCase(reading),
    SaveMushafSettingsUseCase(reading),
    GetSurahsUseCase(quran),
    GetPageInfoUseCase(quran),
    GetPageTajweedCountsUseCase(quran),
    GetQuranBookmarksUseCase(reading),
    ToggleQuranBookmarkUseCase(reading),
    SaveLastReadUseCase(reading),
  );
  await cubit.init(initialPage: 1);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder:
          (_, __) => MaterialApp(
            theme: AppTheme.lightTheme,
            home: AppPaletteScope(
              child: BlocProvider.value(
                value: cubit,
                child: const MushafReaderScreen(initialPage: 1),
              ),
            ),
          ),
    ),
  );
  await tester.pump();
  return cubit;
}

Color _readerBackground(WidgetTester tester) =>
    tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor!;

void main() {
  tearDown(() => ColorsManager.usePalette(AppPalette.light));

  testWidgets('names the surah, juz and page in the header', (tester) async {
    final cubit = await _pumpReader(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('سورة الفاتحة'), findsOneWidget);
    expect(find.text('الجزء ١ · الصفحة ١'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('the page keeps most of the screen below the bars', (
    tester,
  ) async {
    final cubit = await _pumpReader(tester);

    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    final page = tester.getSize(find.byType(PageView));
    expect(page.height, greaterThan(screen.height * 0.75));
    await cubit.close();
  });

  testWidgets('follows the app on automatic paper', (tester) async {
    final cubit = await _pumpReader(tester);

    expect(_readerBackground(tester), MushafPalette.light.paper);
    await cubit.close();
  });

  testWidgets('keeps night paper dark inside a light app', (tester) async {
    final cubit = await _pumpReader(
      tester,
      settings: const MushafReaderSettings(themeMode: MushafThemeMode.night),
    );

    expect(tester.takeException(), isNull);
    expect(_readerBackground(tester), MushafPalette.dark.paper);
    await cubit.close();
  });

  testWidgets('the settings sheet repaints in the paper chosen in it', (
    tester,
  ) async {
    final cubit = await _pumpReader(tester);
    await tester.tap(find.byTooltip('إعدادات القراءة'));
    await tester.pumpAndSettle();
    expect(find.text('لون الصفحة'), findsOneWidget);

    await tester.tap(find.text('ليلي'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      (cubit.state as MushafReaderReady).settings.themeMode,
      MushafThemeMode.night,
    );
    expect(
      AppPaletteOverride.of(tester.element(find.text('لون الصفحة'))),
      same(AppPalette.dark),
    );
    expect(_readerBackground(tester), MushafPalette.dark.paper);
    await cubit.close();
  });

  testWidgets('goes to the page typed into the page dialog', (tester) async {
    final cubit = await _pumpReader(tester);
    await tester.tap(find.byTooltip('الانتقال إلى صفحة'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '٥٠');
    await tester.tap(find.text('انتقال'));
    await tester.pumpAndSettle();

    expect((cubit.state as MushafReaderReady).page, 50);
    await cubit.close();
  });

  testWidgets('the page dialog starts on the current page', (tester) async {
    final cubit = await _pumpReader(tester);
    await tester.tap(find.byTooltip('الانتقال إلى صفحة'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('انتقال'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect((cubit.state as MushafReaderReady).page, 1);
    await cubit.close();
  });

  testWidgets('screen readers can open the page dialog from the page chip', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final cubit = await _pumpReader(tester);

    expect(
      tester.getSemantics(find.bySemanticsLabel(RegExp('الانتقال إلى صفحة'))),
      isSemantics(isButton: true, hasTapAction: true),
    );
    await cubit.close();
    semantics.dispose();
  });

  group('page rules', () {
    const tajweedOn = MushafReaderSettings(tajweedEnabled: true);

    Future<void> openRules(WidgetTester tester) async {
      await tester.tap(find.byTooltip('أحكام التجويد في الصفحة'));
      await tester.pumpAndSettle();
    }

    testWidgets('lists each rule with how often it occurs', (tester) async {
      final cubit = await _pumpReader(
        tester,
        settings: tajweedOn,
        pageCounts: {
          1: const [TajweedRuleCount(ruleKey: 'ikhfa', count: 3)],
        },
      );
      await openRules(tester);

      expect(find.text('٣ مواضع'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await cubit.close();
    });

    testWidgets('says so when none of the rules can be coloured', (
      tester,
    ) async {
      final cubit = await _pumpReader(
        tester,
        settings: tajweedOn,
        pageCounts: {
          1: const [TajweedRuleCount(ruleKey: 'notARule', count: 2)],
        },
      );
      await openRules(tester);

      expect(find.text('لا توجد أحكام ملوّنة في هذه الصفحة'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('offers to switch the colouring on', (tester) async {
      final cubit = await _pumpReader(tester);
      await openRules(tester);

      await tester.tap(find.text('تلوين أحكام التجويد'));
      await tester.pumpAndSettle();

      expect(
        (cubit.state as MushafReaderReady).settings.tajweedEnabled,
        isTrue,
      );
      await cubit.close();
    });
  });

  testWidgets('rejects a page outside the mushaf', (tester) async {
    final cubit = await _pumpReader(tester);
    await tester.tap(find.byTooltip('الانتقال إلى صفحة'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '700');
    await tester.tap(find.text('انتقال'));
    await tester.pump();

    expect(find.text('أدخل رقمًا من ١ إلى ٦٠٤'), findsOneWidget);
    expect((cubit.state as MushafReaderReady).page, 1);
    await cubit.close();
  });
}
