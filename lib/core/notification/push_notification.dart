import 'dart:developer';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mishkat_almasabih/core/notification/firebase_service/notification_handler.dart';
import 'package:mishkat_almasabih/core/notification/hadith_refresh_notifier.dart';
import 'package:mishkat_almasabih/core/notification/local_notification.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/data/datasources/hadeethenc_datasource.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/datasources/daily_hadith_local_datasource.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/repos/daily_hadith_repo_impl.dart';
import 'package:mishkat_almasabih/features/hadith_daily/domain/repos/daily_hadith_repo.dart';
import 'package:mishkat_almasabih/features/hadith_daily/domain/usecases/get_saved_daily_hadith_use_case.dart';
import 'package:mishkat_almasabih/features/hadith_daily/domain/usecases/fetch_daily_hadith_use_case.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("📩 Background message received: ${message.data}");

  final hadithId = message.data['hadithId'];

  if (hadithId != null) {
    final result = await FetchDailyHadithUseCase(_createDailyHadithRepo())(
      hadithId.toString(),
    );

    result.when(
      success: (hadith) {
        log("📖 Hadith fetched and saved in background: ${hadith.title}");

        HadithRefreshNotifier().notifyRefresh();
      },
      failure: (_) => log("❌ Failed to fetch hadith in background"),
    );
  }
}

DailyHadithRepo _createDailyHadithRepo() =>
    DailyHadithRepoImpl(HadeethEncDataSource(), DailyHadithLocalDataSource());

class PushNotification {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? fcmToken;
  static bool _isInitialized = false;

  static GetSavedDailyHadithUseCase get _getSavedHadith => getIt();
  static FetchDailyHadithUseCase get _fetchHadith => getIt();

  static Future<void> init() async {
    if (_isInitialized) {
      log('Push notifications already initialized');
      return;
    }

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('✅ User granted permission for notifications');
    } else {
      log('⚠️ User denied notification permission');
    }

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    try {
      await messaging.subscribeToTopic('daily_hadith');
      await messaging.subscribeToTopic('ramadan');

      await messaging.subscribeToTopic('update');
    } catch (e) {
      log('Retry subscribe later: $e');
    }

    log("📌 Subscribed to topics: daily_hadith, update");

    _setupForegroundNotification();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    _isInitialized = true;
    log('✅ Push notifications initialized successfully');
  }

  static void _setupForegroundNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      log('📩 Foreground message received: ${message.data}');

      final hadithId = message.data['hadithId'];

      if (hadithId != null) {
        log('🔄 Updating hadith in foreground...');

        final result = await _fetchHadith(hadithId.toString());

        result.when(
          success: (newHadith) {
            log("✅ Hadith updated successfully: ${newHadith.title}");

            HadithRefreshNotifier().notifyRefresh();
          },
          failure: (_) => log("❌ Failed to fetch new hadith"),
        );
      }

      if (Platform.isAndroid) {
        await LocalNotification.forgroundNotificationHandler(message);
      }
    });
  }

  static void setupOnTapNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      log("👆 User tapped notification (app in background): ${message.data}");

      final hadithId = message.data['hadithId'];

      if (hadithId != null) {
        final cachedHadith = await _getSavedHadith();

        if (cachedHadith == null || cachedHadith.id.toString() != hadithId) {
          log("⚠️ Hadith not in cache or outdated, fetching...");
          await _fetchHadith(hadithId.toString());

          HadithRefreshNotifier().notifyRefresh();
        }
      }

      await Future.delayed(const Duration(milliseconds: 300));

      await _navigateToHadithScreen();
    });
  }

  static Future<void> handleTerminatedNotification() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      log(
        "🚀 App opened from terminated state with data: ${initialMessage.data}",
      );

      final hadithId = initialMessage.data['hadithId'];

      if (hadithId != null) {
        final hadith = await _getSavedHadith();

        if (hadith == null || hadith.id.toString() != hadithId) {
          log("⚠️ Hadith not found or outdated, fetching now...");
          await _fetchHadith(hadithId.toString());
        }

        HadithRefreshNotifier().notifyRefresh();

        await Future.delayed(const Duration(milliseconds: 800));

        await _navigateToHadithScreen();
      }
    }
  }

  static Future<void> _navigateToHadithScreen() async {
    try {
      final context = navigatorKey.currentContext;

      if (context == null) {
        log("❌ Navigator context is null");
        return;
      }

      final hadith = await _getSavedHadith();

      if (hadith == null) {
        log("❌ No hadith found to navigate to");
        return;
      }

      if (context.mounted) {
        Navigator.of(context).pushNamed(Routes.homeScreen);

        log("✅ Navigated to Hadith Screen");
      }
    } catch (e) {
      log("❌ Navigation error: $e");
    }
  }
}
