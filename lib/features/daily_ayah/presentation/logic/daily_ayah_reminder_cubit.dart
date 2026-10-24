import 'package:mishkat_almasabih/core/notification/notification_toggle/notification_toggle_cubit.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/usecases/get_daily_ayah_reminder_enabled_use_case.dart';
import 'package:mishkat_almasabih/features/daily_ayah/domain/usecases/set_daily_ayah_reminder_enabled_use_case.dart';

/// The daily ayah notification's switch.
class DailyAyahReminderCubit extends NotificationToggleCubit {
  static const String enabledMessage = 'سيصلك إشعار آية اليوم كل صباح';
  static const String disabledMessage = 'تم إيقاف إشعار آية اليوم';

  DailyAyahReminderCubit(
    GetDailyAyahReminderEnabledUseCase getEnabled,
    SetDailyAyahReminderEnabledUseCase setEnabled,
  ) : super(
        isEnabled: getEnabled.call,
        setEnabled: setEnabled.call,
        enabledMessage: enabledMessage,
        disabledMessage: disabledMessage,
      );
}
