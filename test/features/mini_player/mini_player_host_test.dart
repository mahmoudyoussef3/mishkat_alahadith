import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_scope.dart';
import 'package:mishkat_almasabih/core/theming/app_theme.dart';
import 'package:mishkat_almasabih/features/azkar/domain/entities/azkar_audio.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/logic/azkar_audio/azkar_audio_cubit.dart';
import 'package:mishkat_almasabih/features/azkar/presentation/ui/models/azkar_reader_args.dart';
import 'package:mishkat_almasabih/features/mini_player/presentation/logic/mini_player_placement_cubit.dart';
import 'package:mishkat_almasabih/features/mini_player/presentation/ui/docked_mini_player.dart';
import 'package:mishkat_almasabih/features/mini_player/presentation/ui/mini_player_host.dart';
import 'package:mishkat_almasabih/features/mini_player/presentation/ui/mini_player_navigator_observer.dart';

import '../azkar/azkar_fakes.dart';
import '../quran/quran_fakes.dart';

const _track = AzkarAudioTrack(
  audioFile: '75.mp3',
  categoryId: 27,
  zikrId: 3,
  categoryTitle: 'أذكار الصباح والمساء',
  zikrNumber: 3,
);

/// The bottom padding the page on top was last built with.
double _pageRoom = -1;

class _Page extends StatelessWidget {
  const _Page({this.bottomBar});

  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    _pageRoom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      body: const SizedBox.expand(),
      bottomNavigationBar: bottomBar,
    );
  }
}

/// The app's shell around [home], with the azkar's player over [player].
Future<({AzkarAudioCubit azkar, GlobalKey<NavigatorState> navigator})> _pumpApp(
  WidgetTester tester, {
  required FakeAzkarAudioRepo player,
  Widget home = const _Page(),
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  _pageRoom = -1;

  final placement = MiniPlayerPlacementCubit();
  final azkar = audioCubitFor(player);
  final quran = recitationCubit();
  addTearDown(placement.close);
  addTearDown(azkar.close);
  addTearDown(quran.close);
  final navigator = GlobalKey<NavigatorState>();

  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      builder:
          (_, __) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: placement),
              BlocProvider.value(value: azkar),
              BlocProvider.value(value: quran),
            ],
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              navigatorKey: navigator,
              navigatorObservers: [MiniPlayerNavigatorObserver(placement)],
              builder:
                  (context, child) => AppPaletteScope(
                    child: MiniPlayerHost(
                      navigatorKey: navigator,
                      child: child!,
                    ),
                  ),
              home: home,
              onGenerateRoute:
                  (settings) => MaterialPageRoute(
                    settings: settings,
                    builder:
                        (_) => Scaffold(
                          body: Text(
                            'الباب ${(settings.arguments as AzkarReaderArgs).categoryId}',
                          ),
                        ),
                  ),
            ),
          ),
    ),
  );
  await tester.pumpAndSettle();
  return (azkar: azkar, navigator: navigator);
}

void main() {
  late FakeAzkarAudioRepo player;

  setUp(() => player = FakeAzkarAudioRepo()..lastTrack = _track);

  testWidgets('shows nothing, and takes no room, while nothing is on', (
    tester,
  ) async {
    await _pumpApp(tester, player: FakeAzkarAudioRepo());

    expect(find.text(_track.title), findsNothing);
    expect(_pageRoom, 0);
  });

  testWidgets('floats over the page while something is on, making room', (
    tester,
  ) async {
    final app = await _pumpApp(tester, player: player);

    await app.azkar.restore();
    await tester.pumpAndSettle();

    expect(find.text(_track.title), findsOneWidget);
    expect(_pageRoom, greaterThan(0));
  });

  testWidgets('makes way for a dialog over the page', (tester) async {
    final app = await _pumpApp(tester, player: player);
    await app.azkar.restore();
    await tester.pumpAndSettle();

    showDialog<void>(
      context: app.navigator.currentContext!,
      builder: (_) => const AlertDialog(content: Text('حوار')),
    );
    await tester.pumpAndSettle();
    expect(find.text(_track.title), findsNothing);

    app.navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text(_track.title), findsOneWidget);
  });

  testWidgets('a page with its own bar shows it there, once', (tester) async {
    final app = await _pumpApp(
      tester,
      player: player,
      home: const _Page(bottomBar: DockedMiniPlayer()),
    );

    await app.azkar.restore();
    await tester.pumpAndSettle();

    expect(find.text(_track.title), findsOneWidget);
    // The page's bar makes its own room.
    expect(_pageRoom, 0);
  });

  testWidgets('tapping it opens the zikr\'s chapter', (tester) async {
    final app = await _pumpApp(tester, player: player);
    await app.azkar.restore();
    await tester.pumpAndSettle();

    await tester.tap(find.text(_track.title));
    await tester.pumpAndSettle();

    expect(find.text('الباب 27'), findsOneWidget);
    expect(
      app.navigator.currentState!.canPop(),
      isTrue,
      reason: 'opened over the page it was tapped on',
    );
  });

  testWidgets('a recitation failing is said wherever the listener is', (
    tester,
  ) async {
    player.downloadFailure = const NetworkFailure();
    final app = await _pumpApp(tester, player: player);

    await app.azkar.play(_track);
    await tester.pump();

    expect(find.text(FailureMessages.noConnection), findsOneWidget);
    expect(app.azkar.state, isA<AzkarAudioIdle>());
  });
}
