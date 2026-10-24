import 'package:mishkat_almasabih/core/notification/notification_toggle/notification_toggle_cubit.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/get_prayer_pre_reminder_enabled_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/set_prayer_pre_reminder_enabled_use_case.dart';

/// The switch for the reminder shortly before each adhan.
class PrayerPreReminderCubit extends NotificationToggleCubit {
  static const String enabledMessage = 'سيصلك تذكير قبل كل أذان';
  static const String disabledMessage = 'تم إيقاف التذكير قبل الصلاة';

  PrayerPreReminderCubit(
    GetPrayerPreReminderEnabledUseCase getEnabled,
    SetPrayerPreReminderEnabledUseCase setEnabled,
  ) : super(
        isEnabled: getEnabled.call,
        setEnabled: setEnabled.call,
        enabledMessage: enabledMessage,
        disabledMessage: disabledMessage,
      );
}
