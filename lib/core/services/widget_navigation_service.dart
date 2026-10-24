import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/notification/daily_ayah_payload.dart';
import 'package:mishkat_almasabih/core/notification/firebase_service/notification_handler.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/features/hadith_daily/domain/usecases/get_saved_daily_hadith_use_case.dart';

class WidgetNavigationService {
  static const platform = MethodChannel('com.mishkat_almasabih.app/widget');

  static void initialize() {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'openHadithOfTheDay':
          await _navigateToHadithOfTheDay();
          return;
        case 'openPrayerTimes':
          navigatorKey.currentState?.pushNamed(Routes.prayerTimesScreen);
          return;
        case 'openDailyAyah':
          await _openDailyAyah(call.arguments);
          return;
        default:
          return;
      }
    });
    unawaited(_openLaunchDailyAyah());
  }

  /// A widget tap that starts the app comes before Dart is running, too
  /// early to be sent here, so the activity keeps it to be collected.
  static Future<void> _openLaunchDailyAyah() async {
    try {
      final payload = await platform.invokeMethod<String>(
        'takeLaunchDailyAyah',
      );
      if (payload != null) await _openDailyAyah(payload);
    } on MissingPluginException {
      // iOS: there is no daily ayah widget to have been tapped.
    } on PlatformException catch (e) {
      debugPrint('Could not read the daily ayah widget launch: $e');
    }
  }

  /// [arguments] is the payload of the ayah the widget shows. One that
  /// cannot be read opens the Quran's index rather than nothing.
  static Future<void> _openDailyAyah(Object? arguments) async {
    final payload = DailyAyahPayload.tryParse(
      arguments is String ? arguments : null,
    );
    if (payload != null) return OpenDailyAyah(payload).open();
    final navigator = await readyNavigator();
    unawaited(navigator?.pushNamed(Routes.quranScreen));
  }

  static Future<void> _navigateToHadithOfTheDay() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (navigatorKey.currentContext != null) {
      try {
        final hadith = await getIt<GetSavedDailyHadithUseCase>()();

        if (hadith != null) {
          navigatorKey.currentState?.pushNamed(
            Routes.hadithOfTheDay,
            arguments: hadith,
          );
        } else {
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            Routes.homeScreen,
            (route) => false,
          );
        }
      } catch (e) {
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          Routes.homeScreen,
          (route) => false,
        );
      }
    }
  }
}
