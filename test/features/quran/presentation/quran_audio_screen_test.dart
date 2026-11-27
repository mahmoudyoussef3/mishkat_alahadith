import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/theming/app_theme.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/quran_edition.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/filter_quran_editions_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/filter_surahs_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_quran_editions_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_surahs_use_case.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/audio/quran_audio_catalog_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/quran_editions/quran_editions_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/recitation/quran_recitation_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/screens/quran_audio_screen.dart';

import '../quran_fakes.dart';

Future<
  ({
    FakeQuranCloudRepo cloud,
    FakeRecitationPlayerRepo player,
    QuranRecitationCubit cubit,
  })
>
_pump(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final quran = FakeQuranRepo();
  final cloud = FakeQuranCloudRepo(
    recitations: {
      const RecitationScope.surah(1): audioFor([1, 2]),
    },
  );
  final player = FakeRecitationPlayerRepo();
  final cubit = recitationCubit(cloud: cloud, quran: quran, player: player);
  final catalog = QuranAudioCatalogCubit(
    GetSurahsUseCase(quran),
    FilterSurahsUseCase(),
  );
  final editions = QuranEditionsCubit(
    GetQuranEditionsUseCase(cloud),
    FilterQuranEditionsUseCase(),
  );
  addTearDown(cubit.close);
  addTearDown(catalog.close);
  addTearDown(editions.close);
  await catalog.load();
  await editions.load(QuranEditionType.recitation);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder:
          (context, child) => MaterialApp(
            theme: AppTheme.lightTheme,
            home: MultiBlocProvider(
              providers: [
                BlocProvider.value(value: cubit),
                BlocProvider.value(value: catalog),
                BlocProvider.value(value: editions),
              ],
              child: const QuranAudioScreen(),
            ),
          ),
    ),
  );
  await tester.pumpAndSettle();
  return (cloud: cloud, player: player, cubit: cubit);
}

void main() {
  testWidgets('searches reciters and surahs and starts the selected edition', (
    tester,
  ) async {
    final app = await _pump(tester);
    await tester.tap(find.text('القرّاء'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Husary');
    await tester.pumpAndSettle();
    expect(find.text(husary.name), findsOneWidget);
    await tester.tap(find.text(husary.name));
    await tester.pumpAndSettle();

    await tester.tap(find.text('السور'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), '١');
    await tester.pumpAndSettle();
    expect(find.text(baqarah.nameArabic), findsNothing);
    await tester.tap(find.text(fatihah.nameArabic));
    await tester.pump();
    app.player.report(RecitationStatus.playing, 0);
    await tester.pumpAndSettle();

    expect(app.cloud.recitationRequests.first.reciter, husary.identifier);
    expect(
      app.cloud.recitationRequests.first.scope,
      const RecitationScope.surah(1),
    );
    expect(find.text('سورة الفاتحة'), findsOneWidget);
    expect(find.byTooltip('إيقاف مؤقت'), findsOneWidget);
  });

  testWidgets('scrubs the loaded ayah and jumps to another in the queue', (
    tester,
  ) async {
    final app = await _pump(tester);
    await tester.tap(find.byTooltip('تشغيل'));
    await tester.pump();
    final track = app.player.plays.single.tracks.first;
    app.player.progress = (
      url: track.url,
      position: const Duration(seconds: 2),
      duration: const Duration(seconds: 10),
    );
    app.player.report(RecitationStatus.playing, 0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('00:10'), findsOneWidget);
    await tester.tapAt(tester.getCenter(find.byType(Slider)));
    await tester.pumpAndSettle();
    expect(app.player.seeks.single.$1, track.url);
    expect(app.player.seeks.single.$2.inSeconds, inInclusiveRange(4, 5));

    await tester.tap(find.text('الآيات'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('سورة الفاتحة · الآية ٢'));
    await tester.pumpAndSettle();
    expect(app.player.skips, [1]);
    expect(find.text('الآية ٢'), findsOneWidget);
    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
  });

  testWidgets('retries an unavailable recitation from the main control', (
    tester,
  ) async {
    final app = await _pump(tester);
    app.cloud.failure = const NetworkFailure();
    await tester.tap(find.byTooltip('تشغيل'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('إعادة المحاولة'), findsOneWidget);

    app.cloud.failure = null;
    await tester.tap(find.byTooltip('إعادة المحاولة'));
    await tester.pump();
    app.player.report(RecitationStatus.playing, 0);
    await tester.pumpAndSettle();
    expect(app.player.plays, hasLength(1));
    expect(find.byTooltip('إيقاف مؤقت'), findsOneWidget);
  });
}
