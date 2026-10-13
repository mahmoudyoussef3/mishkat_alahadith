import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/theming/splash_decorations.dart';
import 'package:mishkat_almasabih/features/splash/presentation/ui/splash_screen.dart';

const _linkRoute = '/link';

void main() {
  late GlobalKey<NavigatorState> navigatorKey;

  setUp(() => navigatorKey = GlobalKey<NavigatorState>());

  Future<void> pumpApp(WidgetTester tester) async {
    // Phone-sized surface; the splash layout is portrait-only.
    tester.view
      ..physicalSize = const Size(1125, 2436)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder:
            (_, __) => MaterialApp(
              navigatorKey: navigatorKey,
              initialRoute: Routes.splashScreen,
              onGenerateRoute: (settings) {
                final Widget? page = switch (settings.name) {
                  Routes.splashScreen => const SplashScreen(),
                  Routes.homeScreen => const Text('home'),
                  _linkRoute => const Text('link'),
                  _ => null,
                };
                if (page == null) return null;
                return MaterialPageRoute(settings: settings, builder: (_) => page);
              },
            ),
      ),
    );
  }

  // The splash animates forever, so time is advanced explicitly.
  Future<void> passSplashDelay(WidgetTester tester) async {
    await tester.pump(SplashDecorations.navigationDelay);
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('replaces itself with home after the delay', (tester) async {
    await pumpApp(tester);

    await passSplashDelay(tester);

    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('keeps a screen opened over it and puts home beneath', (
    tester,
  ) async {
    await pumpApp(tester);
    navigatorKey.currentState!.pushNamed(_linkRoute);

    await passSplashDelay(tester);

    expect(find.text('link'), findsOneWidget);
    navigatorKey.currentState!.pop();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('home'), findsOneWidget);
  });

  testWidgets('does nothing once it has been removed', (tester) async {
    await pumpApp(tester);
    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      _linkRoute,
      (_) => false,
    );
    await tester.pump(const Duration(seconds: 1));

    await passSplashDelay(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('link'), findsOneWidget);
    expect(find.text('home', skipOffstage: false), findsNothing);
  });

  testWidgets('does nothing when the delay ends while it is animating out', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.pump(
      SplashDecorations.navigationDelay - const Duration(milliseconds: 100),
    );
    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      _linkRoute,
      (_) => false,
    );

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(seconds: 1));

    expect(tester.takeException(), isNull);
    expect(find.text('link'), findsOneWidget);
    expect(find.text('home', skipOffstage: false), findsNothing);
  });
}
