import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/deep_links/deep_link_router.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/helpers/deep_linker_helper.dart';
import 'package:mishkat_almasabih/core/notification/firebase_service/notification_handler.dart';
import 'package:mishkat_almasabih/core/theming/app_palette_scope.dart';
import 'package:mishkat_almasabih/core/theming/app_theme.dart';
import 'package:mishkat_almasabih/features/authentication/session/presentation/logic/session_cubit.dart';
import 'package:mishkat_almasabih/features/theme/domain/entities/app_theme_mode.dart';
import 'package:mishkat_almasabih/features/reading_preferences/presentation/logic/hadith_font_scale_cubit.dart';
import 'package:mishkat_almasabih/features/theme/presentation/logic/theme_cubit.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';

class MishkatAlmasabih extends StatefulWidget {
  final AppRouter appRouter;
  final bool isFirstTime;
  final NavigatorObserver analytics;

  const MishkatAlmasabih({
    super.key,
    required this.appRouter,
    required this.isFirstTime,
    required this.analytics,
  });

  @override
  State<MishkatAlmasabih> createState() => _MishkatAlmasabihState();
}

class _MishkatAlmasabihState extends State<MishkatAlmasabih> {
  final DeepLinkHandler _deepLinkHandler = DeepLinkHandler();

  late final String _startScreen;

  @override
  void initState() {
    super.initState();

    _startScreen =
        widget.isFirstTime ? Routes.onBoardingScreen : Routes.splashScreen;

    log("Start screen: $_startScreen");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _deepLinkHandler.init((uri) async {
        if (kDebugMode) debugPrint('Received deep link: $uri');
        await DeepLinkRouter.handle(uri);
      });
    });
  }

  @override
  void dispose() {
    _deepLinkHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<SessionCubit>()..checkSession()),
        BlocProvider.value(value: getIt<ThemeCubit>()),
        BlocProvider.value(value: getIt<HadithFontScaleCubit>()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return BlocBuilder<ThemeCubit, AppThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                navigatorObservers: [widget.analytics],
                navigatorKey: navigatorKey,
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode.isDark ? ThemeMode.dark : ThemeMode.light,
                // Paints the theme background behind every route, so system
                // bar areas outside a screen's SafeArea are never black, and
                // gives the system bars icons that contrast with it. App bars
                // drawn under the status bar override this with their own.
                builder:
                    (context, child) => AppPaletteScope(
                      child: AnnotatedRegion<SystemUiOverlayStyle>(
                        value: AppTheme.systemBarsStyle(
                          Theme.of(context).brightness,
                        ),
                        child: ColoredBox(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: child!,
                        ),
                      ),
                    ),

                initialRoute: _startScreen,

                onGenerateRoute: widget.appRouter.generateRoute,

                onUnknownRoute: (settings) {
                  log("❌ Unknown route: ${settings.name}");
                  return MaterialPageRoute(
                    builder:
                        (_) => const Scaffold(
                          body: Center(child: Text('Route not found')),
                        ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
