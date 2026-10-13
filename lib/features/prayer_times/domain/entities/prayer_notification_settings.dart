class PrayerNotificationSettings {
  final bool enabled;
  final bool batteryOptimizationIgnored;

  /// When notifications were last scheduled, or null if never.
  final DateTime? lastSyncedAt;

  const PrayerNotificationSettings({
    required this.enabled,
    required this.batteryOptimizationIgnored,
    this.lastSyncedAt,
  });
}
