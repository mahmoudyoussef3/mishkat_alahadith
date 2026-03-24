import 'dart:async';
import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/helpers/deep_linker_helper.dart';
import 'package:mishkat_almasabih/core/deep_links/deep_link_router.dart';
import 'package:mishkat_almasabih/core/notification/firebase_service/notification_handler.dart';
import 'package:mishkat_almasabih/core/notification/local_notification.dart';
import 'package:mishkat_almasabih/core/notification/notification_helper.dart';
import 'package:mishkat_almasabih/core/notification/push_notification.dart';
import 'package:mishkat_almasabih/core/routing/app_router.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/services/widget_navigation_service.dart';
import 'package:mishkat_almasabih/features/onboarding/sava_date_for_first_time.dart';
import 'package:mishkat_almasabih/mishkat_almasabih.dart';
import 'package:mishkat_almasabih/firebase_options.dart';
import 'package:mishkat_almasabih/core/services/hive_service.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/domain/repositories/ramadan_config_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase initialization
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );

  // Local & push notifications setup
  await NotificationHelper.init();
  await LocalNotification.init();
  PushNotification.setupOnTapNotification();
  PushNotification.handleTerminatedNotification();

  // Dependency injection
  await setUpGetIt();

  // Hive setup
  await HiveService.init();

  // Remote Config for Ramadan feature
  await _initializeRamadanRemoteConfig();

  // Date formatting
  await initializeDateFormatting('ar', null);

  // Widget navigation service
  WidgetNavigationService.initialize();

  // Check first-time launch
  final isFirstTime = await SaveDataForFirstTime.isFirstTime();

  // Deep link handling (cold start + runtime)
  final deepLinkHandler = DeepLinkHandler();
  await deepLinkHandler.init((uri) async {
    debugPrint('Received deep link: $uri');
    await DeepLinkRouter.handle(uri);
  });

  // Background messaging handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Crashlytics setup
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Performance monitoring
  await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

  // Run app
  runApp(
    MishkatAlmasabih(
      analytics: observer,
      appRouter: AppRouter(),
      isFirstTime: isFirstTime,
    ),
  );
}

// Remote config helper
Future<void> _initializeRamadanRemoteConfig() async {
  try {
    final remoteConfig = getIt<FirebaseRemoteConfig>();

    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    );

    await remoteConfig.setDefaults(const {
      'ramadan_start_offset': 0,
      'ramadan_total_days': 30,
    });

    final repository = getIt<RamadanConfigRepository>();
    await repository.initializeRemoteConfig();
  } catch (e) {
    print('Failed to initialize Ramadan Remote Config: $e');
  }
}
