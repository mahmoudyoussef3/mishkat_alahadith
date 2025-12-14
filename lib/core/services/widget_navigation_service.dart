import 'package:flutter/services.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/notification/firebase_service/notification_handler.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/repos/save_hadith_daily_repo.dart';

class WidgetNavigationService {
  static const platform = MethodChannel('com.mishkat_almasabih.app/widget');

  static void initialize() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'openHadithOfTheDay') {
        await _navigateToHadithOfTheDay();
      }
    });
  }

  static Future<void> _navigateToHadithOfTheDay() async {
    // Wait a bit to ensure the app is fully initialized
    await Future.delayed(const Duration(milliseconds: 500));

    // Use the global navigator key to navigate
    if (navigatorKey.currentContext != null) {
      try {
        // Get the hadith repository
        final repo = getIt<SaveHadithDailyRepo>();

        // Fetch the current hadith
        final hadith = await repo.getHadith();

        if (hadith != null) {
          // Navigate to the hadith of the day screen with the hadith data
          navigatorKey.currentState?.pushNamed(
            Routes.hadithOfTheDay,
            arguments: hadith,
          );
        } else {
          // If no hadith is available, navigate to home screen
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            Routes.homeScreen,
            (route) => false,
          );
        }
      } catch (e) {
        // On error, just navigate to home screen
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          Routes.homeScreen,
          (route) => false,
        );
      }
    }
  }
}
