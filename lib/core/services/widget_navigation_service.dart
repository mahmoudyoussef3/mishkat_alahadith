import 'package:flutter/services.dart';
import 'package:mishkat_almasabih/core/di/dependency_injection.dart';
import 'package:mishkat_almasabih/core/notification/firebase_service/notification_handler.dart';
import 'package:mishkat_almasabih/core/routing/routes.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/repos/save_hadith_daily_repo.dart';

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
            // Let the shared deep-link pipeline handle it.
            // We only route; the OS-level deep link is handled by app_links.
            final uri = Uri.parse(link);
            navigatorKey.currentState?.pushNamed(
              Routes.deepLinkHadith,
              arguments:
                  uri.pathSegments.isNotEmpty
                      ? uri.pathSegments.last
                      : (uri.queryParameters['id'] ?? ''),
            );
          } catch (_) {
            // Ignore invalid URIs.
          }
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
