import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/theming/app_palette.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_scope.dart';
import 'package:mishkat_almasabih/core/theming/app_theme.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_day_progress.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_settings.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/pause_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/play_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/prepare_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/resume_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/stop_azkar_audio_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/domain/usecases/watch_azkar_playback_use_case.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_audio/azkar_audio_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_reader/azkar_reader_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/models/azkar_reader_args.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/screens/azkar_home_screen.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/screens/azkar_reader_screen.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/widgets/reader/zikr_card.dart';

import '../azkar_fakes.dart';

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

/// A small phone, so tight layouts would overflow here first.
void _useSmallPhone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

AzkarAudioCubit _audioCubit() {
  final player = FakeAzkarAudioRepo();
  return AzkarAudioCubit(
    PrepareAzkarAudioUseCase(player),
    PlayAzkarAudioUseCase(player),
    PauseAzkarAudioUseCase(player),
    ResumeAzkarAudioUseCase(player),
    StopAzkarAudioUseCase(player),
    WatchAzkarPlaybackUseCase(player),
  );
}

Future<AzkarReaderCubit> _pumpReader(
  WidgetTester tester,
  FakeAzkarRepo repo, {
  Brightness brightness = Brightness.light,
}) async {
  _useSmallPhone(tester);
  final reader = readerCubitFor(repo);
  await reader.load(27);
  await tester.pumpWidget(
    _app(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: reader),
          BlocProvider(create: (_) => _audioCubit()),
        ],
        child: const AzkarReaderScreen(args: AzkarReaderArgs(categoryId: 27)),
      ),
      brightness: brightness,
    ),
  );
  await tester.pumpAndSettle();
  return reader;
}

void main() {
  tearDown(() => ColorsManager.usePalette(AppPalette.light));

  for (final brightness in Brightness.values) {
    testWidgets('the azkar home lays out in ${brightness.name} mode', (
      tester,
    ) async {
      _useSmallPhone(tester);
      final repo =
          FakeAzkarRepo()
            ..favoriteIds = [28]
            ..progress = AzkarDayProgress.emptyOn(
              morningClock(),
            ).withCount(27, 1, 1);
      final cubit = homeCubitFor(repo);
      await cubit.load();

      await tester.pumpWidget(
        _app(
          BlocProvider.value(value: cubit, child: const AzkarHomeScreen()),
          brightness: brightness,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('الأذكار'), findsOneWidget);
      expect(find.text('حان وقت أذكار الصباح'), findsOneWidget);
      expect(find.text('المفضلة'), findsOneWidget);
      await cubit.close();
    });

    testWidgets('a chapter lays out in ${brightness.name} mode', (
      tester,
    ) async {
      final reader = await _pumpReader(
        tester,
        FakeAzkarRepo()
          ..settings = AzkarSettings.defaults.copyWith(
            translation: AzkarTranslation.english,
          ),
        brightness: brightness,
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(ZikrCard), findsNWidgets(3));
      expect(find.text('Meaning 27.1'), findsOneWidget);
      await reader.close();
    });
  }

  testWidgets('the home shows search results while searching', (tester) async {
    _useSmallPhone(tester);
    final cubit = homeCubitFor(FakeAzkarRepo());
    await cubit.load();
    await tester.pumpWidget(
      _app(
        BlocProvider.value(value: cubit, child: const AzkarHomeScreen()),
        brightness: Brightness.light,
      ),
    );

    await tester.enterText(find.byType(TextField), 'النوم');
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('الأبواب'), findsOneWidget);
    await cubit.close();
  });

  testWidgets('tapping a zikr counts it down', (tester) async {
    final reader = await _pumpReader(tester, FakeAzkarRepo());

    await tester.tap(find.text('سُبْحَانَ اللَّهِ وَبِحَمْدِهِ'));
    await tester.pumpAndSettle();

    expect((reader.state as AzkarReaderLoaded).countOf(2), 1);
    expect(find.text('بقي مرتان'), findsOneWidget);
    await reader.close();
  });

  testWidgets('finishing the chapter shows the completion card', (
    tester,
  ) async {
    final repo =
        FakeAzkarRepo()
          ..progress = AzkarDayProgress.emptyOn(
            morningClock(),
          ).withCount(27, 1, 1).withCount(27, 2, 3).withCount(27, 3, 99);
    final reader = await _pumpReader(tester, repo);

    reader.count(3);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('أتممت أذكار هذا الباب'), findsOneWidget);
    await reader.close();
  });

  testWidgets('the settings sheet opens over a chapter', (tester) async {
    final reader = await _pumpReader(tester, FakeAzkarRepo());

    await tester.tap(find.byTooltip('إعدادات القراءة'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('الترجمة تحت النص العربي'), findsOneWidget);
    await reader.close();
  });
}
