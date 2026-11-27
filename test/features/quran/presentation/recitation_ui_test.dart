import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/theming/app_palette.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_scope.dart';
import 'package:mishkat_almasabih/core/theming/app_theme.dart';
import 'package:mishkat_almasabih/core/theming/colors.dart';
import 'package:mishkat_almasabih/features/quran/domain/entities/recitation.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_hizb_index_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_mushaf_settings_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_page_info_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_page_tajweed_counts_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_quran_bookmarks_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/get_surahs_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/save_last_read_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/save_mushaf_settings_use_case.dart';
import 'package:mishkat_almasabih/features/quran/domain/usecases/toggle_quran_bookmark_use_case.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/hizb_index/quran_hizb_index_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/mushaf_reader/mushaf_reader_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/logic/recitation/quran_recitation_cubit.dart';
import 'package:mishkat_almasabih/features/quran/presentation/ui/screens/mushaf_reader_screen.dart';

import '../../azkar/azkar_fakes.dart' show FakeAzkarAudioRepo, audioCubitFor;
import '../quran_fakes.dart';

/// The reader on page 1 with a recitation player over [cloud].
///
/// Only the reader's chrome is checked: the page itself loads the mushaf's
/// text from the package's assets, which these tests leave pending.
Future<({QuranRecitationCubit recitation, FakeRecitationPlayerRepo player})>
_pumpReader(WidgetTester tester, FakeQuranCloudRepo cloud) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final quran = FakeQuranRepo();
  final reading = FakeQuranReadingRepo();
  final player = FakeRecitationPlayerRepo();
  final reader = MushafReaderCubit(
    GetMushafSettingsUseCase(reading),
    SaveMushafSettingsUseCase(reading),
    GetSurahsUseCase(quran),
    GetPageInfoUseCase(quran),
    GetPageTajweedCountsUseCase(quran),
    GetQuranBookmarksUseCase(reading),
    ToggleQuranBookmarkUseCase(reading),
    SaveLastReadUseCase(reading),
  );
  final recitation = recitationCubit(
    cloud: cloud,
    quran: quran,
    reading: reading,
    player: player,
  );
  // The mini player docked in the reader's bottom bar shows the azkar too.
  final azkarAudio = audioCubitFor(FakeAzkarAudioRepo());
  addTearDown(reader.close);
  addTearDown(recitation.close);
  addTearDown(azkarAudio.close);
  await reader.init(initialPage: 1);

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder:
          (_, __) => MaterialApp(
            theme: AppTheme.lightTheme,
            home: AppPaletteScope(
              child: MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: reader),
                  BlocProvider.value(value: recitation),
                  BlocProvider.value(value: azkarAudio),
                ],
                child: const MushafReaderScreen(initialPage: 1),
              ),
            ),
          ),
    ),
  );
  await tester.pump();
  return (recitation: recitation, player: player);
}

void main() {
  late FakeQuranCloudRepo cloud;

  setUp(() {
    cloud = FakeQuranCloudRepo(
      recitations: {
        const RecitationScope.surah(1): audioFor([1, 2]),
        const RecitationScope.page(1): audioFor([1, 2]),
      },
    );
    getIt.registerFactory<QuranHizbIndexCubit>(
      () => QuranHizbIndexCubit(GetHizbIndexUseCase(cloud, FakeQuranRepo())),
    );
  });

  tearDown(() async {
    await getIt.reset();
    ColorsManager.usePalette(AppPalette.light);
  });

  testWidgets('no player is docked until a recitation starts', (tester) async {
    await _pumpReader(tester, cloud);

    expect(find.byTooltip('إيقاف التلاوة'), findsNothing);
  });

  testWidgets('docks a player naming the ayah and reciter', (tester) async {
    final reader = await _pumpReader(tester, cloud);

    await reader.recitation.start(const RecitationFromAyah(2));
    reader.player.report(RecitationStatus.playing, 1);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('سورة الفاتحة · الآية ٢'), findsOneWidget);
    expect(find.textContaining('مشاري العفاسي'), findsOneWidget);
    expect(find.byTooltip('إيقاف مؤقت'), findsOneWidget);
  });

  testWidgets('the docked player pauses the recitation', (tester) async {
    final reader = await _pumpReader(tester, cloud);
    await reader.recitation.start(const RecitationFromAyah(1));
    reader.player.report(RecitationStatus.playing, 0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byTooltip('إيقاف مؤقت'));
    await tester.pump();

    expect(reader.player.pauses, 1);
    expect(find.byTooltip('تشغيل'), findsOneWidget);
  });

  testWidgets('offers to try again when the recitation fails', (tester) async {
    cloud.failure = const NetworkFailure();
    final reader = await _pumpReader(tester, cloud);

    await reader.recitation.start(const RecitationFromAyah(1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('تعذر تشغيل التلاوة'), findsOneWidget);
    expect(find.byTooltip('إعادة المحاولة'), findsOneWidget);
  });

  testWidgets('the header opens the recitation sheet', (tester) async {
    await _pumpReader(tester, cloud);

    await tester.tap(find.byTooltip('الاستماع إلى التلاوة'));
    await tester.pumpAndSettle();

    expect(find.text('الاستماع إلى التلاوة'), findsWidgets);
    expect(find.text('السورة كاملة'), findsOneWidget);
    expect(find.text('هذه الصفحة'), findsOneWidget);
  });

  testWidgets('the sheet starts reciting the page being read', (tester) async {
    final reader = await _pumpReader(tester, cloud);
    await tester.tap(find.byTooltip('الاستماع إلى التلاوة'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('هذه الصفحة'));
    // The docked player spins until the player reports, so it never settles.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(cloud.recitationRequests.last.scope, const RecitationScope.page(1));
    expect(reader.player.plays, hasLength(1));
    expect(find.text('ابدأ الاستماع'), findsNothing);
  });
}
