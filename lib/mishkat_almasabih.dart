import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mishkat_almasabih/core/notification/firebase_service/notification_handler.dart';
import 'core/routing/app_router.dart';
import 'core/routing/routes.dart';

class MishkatAlmasabih extends StatelessWidget {
  final AppRouter appRouter;
  final bool isFirstTime;
    final NavigatorObserver analytics;

  //  final bool isLoggedIn;

  const MishkatAlmasabih({
    super.key,
    required this.appRouter,
    required this.isFirstTime,
    required this.analytics,  
    //   required this.isLoggedIn,
  });

  String _getStartScreen() {
    log("Determining start screen...");

    if (isFirstTime) {
      log("Going to onboarding screen");
      return Routes.onBoardingScreen;
    } else {
      log("Going to splash screen");
      return Routes.splashScreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    log("isFirstTime is $isFirstTime");
    //log("is logged in $isLoggedIn");

    final startScreen = _getStartScreen();
    log("Start screen: $startScreen");

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          navigatorObservers: [analytics],
          navigatorKey: navigatorKey,
          title: 'مشكاة الأحاديث',
          theme: ThemeData(
            fontFamily: 'Cairo',
            useMaterial3: true, // إضافة Material 3
          ),
          debugShowCheckedModeBanner: false,
          initialRoute: _getStartScreen(),
          onGenerateRoute: appRouter.generateRoute,

          onUnknownRoute: (settings) {
            log("Unknown route: ${settings.name}");
            return MaterialPageRoute(
              builder:
                  (context) => Scaffold(
                    appBar: AppBar(title: const Text('خطأ')),
                    body: const Center(child: Text('الصفحة غير موجودة')),
                  ),
            );
          },

          home: null, 
        );
      },
    );
  }
}
