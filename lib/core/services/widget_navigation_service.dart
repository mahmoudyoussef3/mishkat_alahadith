import 'package:flutter/services.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
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
        case 'openHadithLink':
          final link = call.arguments as String?;
          if (link == null || link.trim().isEmpty) return;
          try {
            final uri = Uri.parse(link);
            navigatorKey.currentState?.pushNamed(
              Routes.shareHadithLink,
              arguments:
                  uri.pathSegments.isNotEmpty
                      ? uri.pathSegments.last
                      : (uri.queryParameters['id'] ?? ''),
            );
          } catch (_) {}
          return;
        case 'openPrayerTimes':
          navigatorKey.currentState?.pushNamed(Routes.prayerTimesScreen);
          return;
        default:
          return;
      }
    });
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
