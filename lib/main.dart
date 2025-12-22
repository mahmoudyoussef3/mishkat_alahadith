import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/notification/local_notification.dart';
import 'package:mishkat_almasabih/core/notification/push_notification.dart';
import 'package:mishkat_almasabih/core/routing/app_router.dart';
import 'package:mishkat_almasabih/core/services/widget_navigation_service.dart';
import 'package:mishkat_almasabih/features/onboarding/sava_date_for_first_time.dart';
import 'package:mishkat_almasabih/mishkat_almasabih.dart';
import 'package:mishkat_almasabih/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'mishkat_almasabih.dart';
import 'package:flutter/rendering.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);
  //await Firebase.initializeApp();

  // تهيئة الـ FCM (مرة واحدة بس)
 // await PushNotification.init();
  // Setup notification tap handlers
  await LocalNotification.init();
  //await PushNotification.getApnsToken();

  // إعداد tap على النوتيفيكيشن
  PushNotification.setupOnTapNotification();

  // معالجة لو الأبلكيشن فتح من نوتيفيكيشن (terminated state)
  PushNotification.handleTerminatedNotification();

  await setUpGetIt();
  await initializeDateFormatting('ar', null);

  // Initialize widget navigation service to handle widget clicks
  WidgetNavigationService.initialize();

  //final prefs = await SharedPreferences.getInstance();
  //final token = prefs.getString('token');
  // final isLoggedIn = token != null;
  final isFirstTime = await SaveDataForFirstTime.isFirstTime();

  final app = MishkatAlmasabih(
    analytics: observer,
    appRouter: AppRouter(),
    isFirstTime: isFirstTime,
    // isLoggedIn: isLoggedIn,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  // ربط Flutter errors بـ Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // التعامل مع الأخطاء الغير متوقعة (خارج Flutter)
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);
 // debugRepaintRainbowEnabled = true;

  runApp(app);
}
