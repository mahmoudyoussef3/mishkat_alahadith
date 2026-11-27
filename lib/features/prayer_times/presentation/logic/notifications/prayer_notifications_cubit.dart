import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/get_prayer_notification_settings_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/get_saved_prayer_location_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/open_battery_optimization_settings_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/reschedule_prayer_notifications_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/set_prayer_notifications_enabled_use_case.dart';

part 'prayer_notifications_state.dart';

class PrayerNotificationsCubit extends Cubit<PrayerNotificationsState> {
  final GetPrayerNotificationSettingsUseCase _getSettings;
  final SetPrayerNotificationsEnabledUseCase _setEnabled;
  final ReschedulePrayerNotificationsUseCase _reschedule;
  final OpenBatteryOptimizationSettingsUseCase _openBatterySettings;
  final GetSavedPrayerLocationUseCase _getSavedLocation;

  PrayerNotificationsCubit(
    this._getSettings,
    this._setEnabled,
    this._reschedule,
    this._openBatterySettings,
    this._getSavedLocation,
  ) : super(const PrayerNotificationsState());

  Future<void> load() async {
    final (result, location) = await (_getSettings(), _getSavedLocation()).wait;
    if (isClosed) return;
    final current = state.copyWith(locationName: location.cityName);
    emit(
      result.when(
        success:
            (settings) => current.copyWith(
              enabled: settings.enabled,
              batteryOptimizationIgnored: settings.batteryOptimizationIgnored,
              lastSyncedAt: settings.lastSyncedAt,
            ),
        failure: (_) => current,
      ),
    );
  }

  Future<void> toggle(bool enabled) async {
    if (state.isBusy) return;
    emit(state.copyWith(isBusy: true));

    final result = await _setEnabled(enabled);
    final lastSyncedAt = await _lastSyncedAt();
    emit(
      result.when(
        success:
            (message) => state.copyWith(
              isBusy: false,
              enabled: enabled,
              lastSyncedAt: lastSyncedAt,
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
    final lastSyncedAt = await _lastSyncedAt();
    emit(
      result.when(
        success:
            (message) => state.copyWith(
              isBusy: false,
              lastSyncedAt: lastSyncedAt,
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

  /// Re-reads the sync time after an action may have rescheduled.
  Future<DateTime?> _lastSyncedAt() async {
    final result = await _getSettings();
    return switch (result) {
      ApiSuccess(:final data) => data.lastSyncedAt,
      ApiFailure() => null,
    };
  }
}
