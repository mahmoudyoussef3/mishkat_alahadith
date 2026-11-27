import 'package:mishkat_almasabih/core/notification/notification_toggle/notification_toggle_cubit.dart';
import 'package:mishkat_almasabih/features/quran_wird/domain/usecases/get_quran_wird_reminder_enabled_use_case.dart';
import 'package:mishkat_almasabih/features/quran_wird/domain/usecases/set_quran_wird_reminder_enabled_use_case.dart';

/// The daily wird reminder's switch.
class QuranWirdReminderCubit extends NotificationToggleCubit {
  static const String enabledMessage = 'سيصلك تذكير بوردك من القرآن كل يوم';
  static const String disabledMessage = 'تم إيقاف تذكير الورد اليومي';

  QuranWirdReminderCubit(
    GetQuranWirdReminderEnabledUseCase getEnabled,
    SetQuranWirdReminderEnabledUseCase setEnabled,
  ) : super(
        isEnabled: getEnabled.call,
        setEnabled: setEnabled.call,
        enabledMessage: enabledMessage,
        disabledMessage: disabledMessage,
      );
}
