import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/get_prayer_notification_settings_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/open_battery_optimization_settings_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/reschedule_prayer_notifications_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/set_prayer_notifications_enabled_use_case.dart';

part 'prayer_notifications_state.dart';

class PrayerNotificationsCubit extends Cubit<PrayerNotificationsState> {
  final GetPrayerNotificationSettingsUseCase _getSettings;
  final SetPrayerNotificationsEnabledUseCase _setEnabled;
  final ReschedulePrayerNotificationsUseCase _reschedule;
  final OpenBatteryOptimizationSettingsUseCase _openBatterySettings;

  PrayerNotificationsCubit(
    this._getSettings,
    this._setEnabled,
    this._reschedule,
    this._openBatterySettings,
  ) : super(const PrayerNotificationsState());

  Future<void> load() async {
    final result = await _getSettings();
    result.when(
      success:
          (settings) => emit(
            state.copyWith(
              enabled: settings.enabled,
              batteryOptimizationIgnored: settings.batteryOptimizationIgnored,
            ),
          ),
      failure: (_) {},
    );
  }

  Future<void> toggle(bool enabled) async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true));

    final result = await _setEnabled(enabled);
    emit(
      result.when(
        success:
            (message) => state.copyWith(
              isBusy: false,
              enabled: enabled,
              notice: PrayerNotificationsNotice(message),
            ),
        failure:
            (failure) => state.copyWith(
              isBusy: false,
              notice: PrayerNotificationsNotice(failure.message, isError: true),
            ),
      ),
    );
  }

  Future<void> refresh() async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true));

    final result = await _reschedule();
    emit(
      result.when(
        success:
            (message) => state.copyWith(
              isBusy: false,
              notice: PrayerNotificationsNotice(message),
            ),
        failure:
            (failure) => state.copyWith(
              isBusy: false,
              notice: PrayerNotificationsNotice(failure.message, isError: true),
            ),
      ),
    );
  }

  Future<void> improveReliability() async {
    await _openBatterySettings();
    await load();
  }
}
