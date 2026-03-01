import 'dart:ui';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/notification/local_notification.dart';
import 'package:mishkat_almasabih/core/notification/notification_helper.dart';
import 'package:mishkat_almasabih/core/notification/push_notification.dart';
import 'package:mishkat_almasabih/core/routing/app_router.dart';
import 'package:mishkat_almasabih/core/services/widget_navigation_service.dart';
import 'package:mishkat_almasabih/features/onboarding/sava_date_for_first_time.dart';
import 'package:mishkat_almasabih/features/daily_zekr/logic/cubit/daily_zekr_cubit.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/services/prayer_times_reminder_service.dart';
import 'package:mishkat_almasabih/features/prayer_times/data/services/asr_method_preference.dart';
import 'package:mishkat_almasabih/mishkat_almasabih.dart';
import 'package:mishkat_almasabih/firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/rendering.dart';
import 'package:mishkat_almasabih/core/services/hive_service.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/domain/repositories/ramadan_config_repository.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );
   await NotificationHelper.init();
  await LocalNotification.init();

  PushNotification.setupOnTapNotification();

  PushNotification.handleTerminatedNotification();

  await setUpGetIt();

  // Initialize Hive for local persistence (e.g., Ramadan Tasks feature)
  await HiveService.init();

  // Initialize Firebase Remote Config for Ramadan date adjustments
  // This allows controlling Ramadan start and duration without app updates
  await _initializeRamadanRemoteConfig();

  try {
    await DailyZekrCubit(getIt()).init();
  } catch (_) {}

  // Schedule prayer-time notifications for today + tomorrow on every app launch.
  // Load user's Asr method preference first so it's cached for sync access.
  try {
    final asrMethod = await AsrMethodPreference.load();
    await getIt<PrayerTimesReminderService>().scheduleFromNow(
      asrMethod: asrMethod,
    );
  } catch (_) {}

  await initializeDateFormatting('ar', null);

  WidgetNavigationService.initialize();

  final isFirstTime = await SaveDataForFirstTime.isFirstTime();

  final app = MishkatAlmasabih(
    analytics: observer,
    appRouter: AppRouter(),
    isFirstTime: isFirstTime,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

  runApp(app);
}

/// Initializes Firebase Remote Config for Ramadan date adjustments.
///
/// Why Remote Config for Ramadan?
/// Islamic months (Shaban & Ramadan) can be 29 or 30 days based on moon sighting.
/// This isn't known until official announcements. Remote Config allows immediate
/// adjustments for all users without app updates - critical for production apps.
///
/// Configuration Parameters:
/// 1. ramadan_start_offset: Adjust when Ramadan begins
///    - 0: Use calculated date (Shaban has 30 days) - DEFAULT
///    - +1: Start 1 day earlier (Shaban has only 29 days)
///    - -1: Start 1 day later (for corrections)
///
/// 2. ramadan_total_days: Total days in Ramadan
///    - 30: Full month (default)
///    - 29: Short month (based on moon sighting)
///
/// Example Scenario:
/// If Shaban is announced to have 29 days (not 30):
/// → Set ramadan_start_offset = 1
/// → Ramadan starts 1 day earlier than calculated
/// → All users see correct dates within 1 hour (or on restart)
///
/// Configuration:
/// - Minimum fetch interval: 1 hour (production)
/// - Default values ensure app never crashes if Remote Config fails
/// - Values are cached locally for offline use
Future<void> _initializeRamadanRemoteConfig() async {
  try {
    final remoteConfig = getIt<FirebaseRemoteConfig>();

    // Set config settings for production use
    // Minimum fetch interval: 1 hour (3600 seconds)
    // This prevents excessive API calls while allowing timely updates
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    );

    // Set default values to use if Remote Config is unavailable
    // These defaults ensure the app works even if Firebase is down
    await remoteConfig.setDefaults(const {
      'ramadan_start_offset': 0, // No adjustment by default
      'ramadan_total_days': 30, // Assume 30 days by default
    });

    // Fetch and activate the latest config from Firebase
    final repository = getIt<RamadanConfigRepository>();
    await repository.initializeRemoteConfig();
  } catch (e) {
    // Log but don't throw - app should continue with default values
    // The fallback mechanism ensures the app never crashes
    // ignore: avoid_print
    print('Failed to initialize Ramadan Remote Config: $e');
  }
}
