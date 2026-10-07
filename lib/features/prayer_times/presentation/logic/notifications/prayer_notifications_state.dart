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

  /// When notifications were last scheduled, or null if never.
  final DateTime? lastSyncedAt;

  /// City the prayer times are calculated for, once loaded.
  final String? locationName;

  const PrayerNotificationsState({
    this.enabled = false,
    this.batteryOptimizationIgnored = true,
    this.isBusy = false,
    this.notice,
    this.lastSyncedAt,
    this.locationName,
  });

  bool get showBatteryReliabilityAction =>
      enabled && !batteryOptimizationIgnored;

  PrayerNotificationsState copyWith({
    bool? enabled,
    bool? batteryOptimizationIgnored,
    bool? isBusy,
    PrayerNotificationsNotice? notice,
    DateTime? lastSyncedAt,
    String? locationName,
  }) {
    return PrayerNotificationsState(
      enabled: enabled ?? this.enabled,
      batteryOptimizationIgnored:
          batteryOptimizationIgnored ?? this.batteryOptimizationIgnored,
      isBusy: isBusy ?? this.isBusy,
      notice: notice,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      locationName: locationName ?? this.locationName,
    );
  }
}
