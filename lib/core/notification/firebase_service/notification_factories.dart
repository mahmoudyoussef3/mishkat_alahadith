
import 'package:mishkat_almasabih/core/notification/daily_ayah_payload.dart';
import 'package:mishkat_almasabih/core/notification/firebase_service/notification_handler.dart';
import 'package:mishkat_almasabih/core/notification/notification_payloads.dart';

class NotificationHandlerFactory {
  static final Map<String, NotificationHandler> onTapHandler = {
    'project_status': ProjectStatus(),
    'order_status': OrderStatus(),
    'credit': AddCredit(),
    'cart': CheckCart(),
    'favorite': CheckFavorite(),
    NotificationPayloads.quranWird: OpenQuranWird(),
  };
  static NotificationHandler? getHandler(String type) {
    // Carries the ayah to open, so it is parsed rather than looked up.
    final dailyAyah = DailyAyahPayload.tryParse(type);
    if (dailyAyah != null) return OpenDailyAyah(dailyAyah);
    return onTapHandler[type];
  }
}
