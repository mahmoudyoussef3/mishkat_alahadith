import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Remote data source for Ramadan configuration using Firebase Remote Config.
///
/// Why Remote Config for Ramadan?
/// Islamic months (Shaban & Ramadan) can be 29 or 30 days based on moon sighting.
/// This isn't known until official announcements. Remote Config allows instant
/// adjustments for all users without app updates - critical for production apps.
///
/// Configuration Parameters:
/// - ramadan_start_offset: Adjust Ramadan start date (+1 if Shaban is 29, 0 if 30, -1 for correction)
/// - ramadan_total_days: Total days in Ramadan (29 or 30 based on moon sighting)
///
/// Example Scenario:
/// Shaban is announced to have 29 days (not 30):
/// → Set ramadan_start_offset = 1 (Ramadan starts 1 day earlier than calculated)
/// → Users see correct Ramadan start date immediately
abstract class RamadanConfigRemoteDataSource {
  /// Fetches and activates the latest remote configuration.
  /// Safe to call multiple times - Firebase handles caching and rate limiting.
  Future<void> fetchAndActivate();

  /// Gets the Ramadan start date offset in days.
  ///
  /// Returns:
  /// - 0: Use calculated date (Shaban has 30 days)
  /// - +1: Start 1 day earlier (Shaban has 29 days)
  /// - -1: Start 1 day later (correction if needed)
  ///
  /// Default: 0 (use calculated dates)
  int getRamadanStartOffset();

  /// Gets the total number of days in Ramadan.
  ///
  /// Returns:
  /// - 30: Ramadan has 30 days (default)
  /// - 29: Ramadan has 29 days (based on moon sighting)
  ///
  /// Default: 30 days
  int getRamadanTotalDays();

  /// Gets the Gregorian start date of Ramadan.
  ///
  /// Returns:
  /// - A date string in 'yyyy-MM-dd' format (e.g., '2026-03-19')
  /// - Empty string if not configured
  ///
  /// This is the primary method for determining Ramadan timing,
  /// eliminating country-specific Hijri calculation discrepancies.
  String getRamadanStartGregorian();
}

class RamadanConfigRemoteDataSourceImpl
    implements RamadanConfigRemoteDataSource {
  final FirebaseRemoteConfig _remoteConfig;

  /// Key for Ramadan start date offset
  static const String _ramadanStartOffsetKey = 'ramadan_start_offset';

  /// Key for total days in Ramadan
  static const String _ramadanTotalDaysKey = 'ramadan_total_days';

  /// Key for Gregorian start date of Ramadan
  static const String _ramadanStartGregorianKey = 'ramadan_start_gregorian';

  /// Default values for safe fallback
  static const int _defaultStartOffset = 0;
  static const int _defaultTotalDays = 30;
  static const String _defaultStartGregorian = '';

  RamadanConfigRemoteDataSourceImpl({
    required FirebaseRemoteConfig remoteConfig,
  }) : _remoteConfig = remoteConfig;

  @override
  Future<void> fetchAndActivate() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // Log but don't throw - app should continue with defaults
      // ignore: avoid_print
      print('Failed to fetch Ramadan Remote Config: $e');
    }
  }

  @override
  int getRamadanStartOffset() {
    try {
      final offset = _remoteConfig.getInt(_ramadanStartOffsetKey);
      // Clamp to reasonable range (-2 to +2 days)
      return offset.clamp(-2, 2);
    } catch (e) {
      // ignore: avoid_print
      print('Failed to read ramadan_start_offset: $e');
      return _defaultStartOffset;
    }
  }

  @override
  int getRamadanTotalDays() {
    try {
      final days = _remoteConfig.getInt(_ramadanTotalDaysKey);
      // Islamic months are always 29 or 30 days
      return days == 29 ? 29 : 30;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to read ramadan_total_days: $e');
      return _defaultTotalDays;
    }
  }

  @override
  String getRamadanStartGregorian() {
    try {
      final startDate = _remoteConfig.getString(_ramadanStartGregorianKey);
      // Return empty string if not configured
      return startDate;
    } catch (e) {
      // ignore: avoid_print
      print('Failed to read ramadan_start_gregorian: $e');
      return _defaultStartGregorian;
    }
  }
}
