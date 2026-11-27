import 'package:mishkat_almasabih/core/networking/api_result.dart';

/// The daily reminder to read one's wird of the Quran.
abstract class QuranWirdRepo {
  /// Whether the reader wants the reminder and the system lets the app post
  /// it.
  Future<ApiResult<bool>> isReminderEnabled();

  /// Saves the reader's choice. Turning it on asks for the notification
  /// permission, and fails if it is refused.
  Future<ApiResult<void>> setReminderEnabled(bool enabled);

  /// Replaces any pending reminder with one every day at [hour]:[minute].
  Future<ApiResult<void>> scheduleDailyReminder({
    required int hour,
    required int minute,
  });

  Future<ApiResult<void>> cancelReminder();
}
