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
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/notification/local_notification.dart';
import 'package:mishkat_almasabih/core/notification/notification_helper.dart';
import 'package:mishkat_almasabih/core/notification/prayer_time_notification_scheduler.dart';
import 'package:mishkat_almasabih/core/notification/push_notification.dart';
import 'package:mishkat_almasabih/core/routing/app_router.dart';
import 'package:mishkat_almasabih/core/services/hive_service.dart';
import 'package:mishkat_almasabih/core/services/prayer_times_home_widget_sync.dart';
import 'package:mishkat_almasabih/core/services/prayer_times_widget_background_worker.dart';
import 'package:mishkat_almasabih/core/services/widget_navigation_service.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/usecases/sync_daily_ayah_use_case.dart';
import 'package:mishkat_almasabih/features/hadith_daily/domain/usecases/sync_daily_hadith_notification_use_case.dart';
import 'package:mishkat_almasabih/features/quran_wird/domain/usecases/sync_quran_wird_reminder_use_case.dart';
import 'package:mishkat_almasabih/features/onboarding/domain/usecases/is_first_launch_use_case.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/domain/usecases/initialize_ramadan_config_use_case.dart';
import 'package:mishkat_almasabih/features/theme/presentation/logic/theme_cubit.dart';
import 'package:mishkat_almasabih/features/reading_preferences/presentation/logic/hadith_font_scale_cubit.dart';
import 'package:mishkat_almasabih/firebase_options.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'mishkat_almasabih.dart';

Future<void> bootstrapApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(
    analytics: analytics,
  );

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Must run after the Crashlytics handlers above: Sentry wraps the existing
  // error handlers, so both Crashlytics and Sentry keep receiving errors.
  await _runIsolated('SentryFlutter.init', _initializeSentry);

  await setUpGetIt();
  await HiveService.init();
  await initializeDateFormatting('ar', null);

  WidgetNavigationService.initialize();

  final isFirstTime = await getIt<IsFirstLaunchUseCase>()();
  await Future.wait([
    getIt<ThemeCubit>().load(),
    getIt<HadithFontScaleCubit>().load(),
  ]);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(
    MishkatAlmasabih(
      analytics: observer,
      appRouter: AppRouter(),
      isFirstTime: isFirstTime,
    ),
  );

  unawaited(_initializeBackgroundServices());
}

// A DSN is public by design: it only allows sending events, not reading them.
const _sentryDsn =
    'https://9a662228433950e5a027dd66d34c9a4e@o4511762064998400.ingest.us.sentry.io/4511762243518464';

Future<void> _initializeSentry() {
  return SentryFlutter.init((options) {
    options.dsn = _sentryDsn;
  });
}

Future<void> _initializeBackgroundServices() async {
  // First: reading how the app was launched needs no initialising, and
  // LocalNotification.init can stop on a system settings screen, which would
  // hold back the screen a tapped notification opens.
  await _runIsolated(
    'LocalNotification.handleLaunchNotification',
    LocalNotification.handleLaunchNotification,
  );
  await _runIsolated('NotificationHelper.init', NotificationHelper.init);
  await _runIsolated('LocalNotification.init', LocalNotification.init);
  await _runIsolated(
    'PrayerNotificationScheduler.bootstrap',
    PrayerNotificationScheduler.bootstrap,
  );
  await _runIsolated(
    'PrayerTimesWidgetBackgroundWorker.initialize',
    PrayerTimesWidgetBackgroundWorker.initialize,
  );
  await _runIsolated(
    'PrayerTimesHomeWidgetSync.refresh',
    PrayerTimesHomeWidgetSync.refresh,
  );
  await _runIsolated('PushNotification.setupOnTapNotification', () async {
    PushNotification.setupOnTapNotification();
  });
  await _runIsolated(
    'PushNotification.handleTerminatedNotification',
    PushNotification.handleTerminatedNotification,
  );
  await _runIsolated(
    'FirebasePerformance.setPerformanceCollectionEnabled',
    () => FirebasePerformance.instance.setPerformanceCollectionEnabled(true),
  );
  await _runIsolated(
    '_initializeRamadanRemoteConfig',
    _initializeRamadanRemoteConfig,
  );
  // Last, so a tapped push is handled first: these can take a while, and
  // the topic sync waits on the network.
  await _runIsolated('SyncDailyAyahUseCase', _syncDailyAyah);
  await _runIsolated('SyncQuranWirdReminderUseCase', _syncQuranWird);
  await _runIsolated(
    'SyncDailyHadithNotificationUseCase',
    _syncDailyHadithNotification,
  );
}

/// Readies the coming days of "آية اليوم" — widget and notifications.
Future<void> _syncDailyAyah() async {
  final result = await getIt<SyncDailyAyahUseCase>()();
  if (result case ApiFailure(:final failure)) {
    throw StateError('Daily ayah sync failed: $failure');
  }
}

/// Sets the daily wird reminder again if it is on, in case it was lost.
Future<void> _syncQuranWird() async {
  final result = await getIt<SyncQuranWirdReminderUseCase>()();
  if (result case ApiFailure(:final failure)) {
    throw StateError('Quran wird reminder sync failed: $failure');
  }
}

/// Subscribes to the "حديث اليوم" push, or leaves it, as the reader chose.
/// Offline is expected here and retried on the next start, so it is only
/// logged.
Future<void> _syncDailyHadithNotification() async {
  final result = await getIt<SyncDailyHadithNotificationUseCase>()();
  if (result case ApiFailure(:final failure)) {
    debugPrint('Daily hadith notification not synced yet: $failure');
  }
}

Future<void> _runIsolated(String label, Future<void> Function() step) async {
  try {
    await step();
  } catch (e, stackTrace) {
    debugPrint('Failed to initialize background service "$label": $e');
    FirebaseCrashlytics.instance.recordError(e, stackTrace, fatal: false);
  }
}

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

    await getIt<InitializeRamadanConfigUseCase>()();
  } catch (e) {
    debugPrint('Failed to initialize Ramadan Remote Config: $e');
  }
}
