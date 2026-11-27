import 'package:mishkat_almasabih/core/networking/api_result.dart';

/// Whether the day's hadith reaches the reader as a notification.
abstract class DailyHadithNotificationRepo {
  /// Whether the reader wants it and the system lets the app post it.
  Future<ApiResult<bool>> isEnabled();

  /// Saves the reader's choice. Turning it on asks for the notification
  /// permission, and fails if it is refused.
  Future<ApiResult<void>> setEnabled(bool enabled);

  /// Has the server send the notification to this device, or stop, as the
  /// reader chose.
  Future<ApiResult<void>> syncSubscription();
}
