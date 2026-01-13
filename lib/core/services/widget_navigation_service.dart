import 'package:flutter/services.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/notification/firebase_service/notification_handler.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/repos/save_hadith_daily_repo.dart';

class WidgetNavigationService {
  static const platform = MethodChannel('com.mishkat_almasabih.app/widget');

  static void initialize() {
    platform.setMethodCallHandler((call) async {
        await _navigateToHadithOfTheDay();
    
    });
  }

  static Future<void> _navigateToHadithOfTheDay() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (navigatorKey.currentContext != null) {
      try {
        final repo = getIt<SaveHadithDailyRepo>();

        final hadith = await repo.getHadith();

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
