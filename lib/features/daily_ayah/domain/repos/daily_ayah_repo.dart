import 'package:mishkat_almasabih/core/networking/api_result.dart';

import '../entities/ayah_reference.dart';
import '../entities/daily_ayah.dart';

/// "آية اليوم": which ayahs are featured, and how each day's ayah reaches the
/// reader — the home screen widget and a daily notification.
abstract class DailyAyahRepo {
  /// The ayahs the days rotate through, in catalog order.
  Future<ApiResult<List<AyahReference>>> getCatalog();

  /// Hands the widget [ayahs], one per day, so it moves on to the next one
  /// each midnight without the app being opened.
  Future<ApiResult<void>> updateHomeWidget(List<DailyAyah> ayahs);

  /// Replaces every pending daily ayah notification with [reminders].
  Future<ApiResult<void>> scheduleReminders(List<DailyAyahReminder> reminders);

  Future<ApiResult<void>> cancelReminders();

  /// Whether the reader wants the daily notification and the system lets the
  /// app post it.
  Future<ApiResult<bool>> isReminderEnabled();

  /// Saves the reader's choice. Turning it on asks for the notification
  /// permission, and fails if it is refused.
  Future<ApiResult<void>> setReminderEnabled(bool enabled);
}
