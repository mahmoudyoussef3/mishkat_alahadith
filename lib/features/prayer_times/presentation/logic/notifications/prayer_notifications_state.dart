part of 'prayer_notifications_cubit.dart';

class PrayerNotificationsNotice {
  final String message;
  final bool isError;

  PrayerNotificationsNotice(this.message, {this.isError = false});
}

class PrayerNotificationsState {
  final bool enabled;
  final bool batteryOptimizationIgnored;
  final bool isBusy;
  final PrayerNotificationsNotice? notice;

  const PrayerNotificationsState({
    this.enabled = false,
    this.batteryOptimizationIgnored = true,
    this.isBusy = false,
    this.notice,
  });

  bool get showBatteryReliabilityAction =>
      enabled && !batteryOptimizationIgnored;

  PrayerNotificationsState copyWith({
    bool? enabled,
    bool? batteryOptimizationIgnored,
    bool? isBusy,
    PrayerNotificationsNotice? notice,
  }) {
    return PrayerNotificationsState(
      enabled: enabled ?? this.enabled,
      batteryOptimizationIgnored:
          batteryOptimizationIgnored ?? this.batteryOptimizationIgnored,
      isBusy: isBusy ?? this.isBusy,
      notice: notice,
    );
  }
}
