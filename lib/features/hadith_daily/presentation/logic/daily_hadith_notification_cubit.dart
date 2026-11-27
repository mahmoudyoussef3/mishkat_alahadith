import 'package:mishkat_almasabih/core/notification/notification_toggle/notification_toggle_cubit.dart';
import 'package:mishkat_almasabih/features/hadith_daily/domain/usecases/get_daily_hadith_notification_enabled_use_case.dart';
import 'package:mishkat_almasabih/features/hadith_daily/domain/usecases/set_daily_hadith_notification_enabled_use_case.dart';

/// The "حديث اليوم" notification's switch.
class DailyHadithNotificationCubit extends NotificationToggleCubit {
  static const String enabledMessage = 'سيصلك حديث اليوم كل يوم';
  static const String disabledMessage = 'تم إيقاف إشعار حديث اليوم';

  DailyHadithNotificationCubit(
    GetDailyHadithNotificationEnabledUseCase getEnabled,
    SetDailyHadithNotificationEnabledUseCase setEnabled,
  ) : super(
        isEnabled: getEnabled.call,
        setEnabled: setEnabled.call,
        enabledMessage: enabledMessage,
        disabledMessage: disabledMessage,
      );
}
