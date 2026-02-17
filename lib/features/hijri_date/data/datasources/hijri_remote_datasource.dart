import 'package:firebase_remote_config/firebase_remote_config.dart';

/// Remote data source for Hijri date configuration using Firebase Remote Config.
///
/// Why Firebase Remote Config?
/// - Allows updating Hijri date offset globally for all users without app updates
/// - Essential for adjusting Islamic calendar when official sighting differs from calculations
/// - Provides immediate fix capability for date discrepancies
///
/// This datasource handles:
/// - Fetching remote configuration from Firebase
/// - Activating fetched config
/// - Reading the hijri_offset integer value
/// - Providing safe fallback when Remote Config is unavailable
abstract class HijriRemoteDataSource {
  /// Fetches and activates the latest remote configuration.
  ///
  /// Should be called on app startup to ensure fresh config.
  /// Safe to call multiple times - Firebase handles caching and rate limiting.
  Future<void> fetchAndActivate();

  /// Gets the Hijri date offset value from Remote Config.
  ///
  /// Returns the offset (in days) to adjust Hijri dates.
  /// - Positive values: add days to calculated date
  /// - Negative values: subtract days from calculated date
  /// - Zero: no adjustment needed
  ///
  /// Fallback behavior:
  /// If Remote Config fails or key doesn't exist, returns 0 (no offset).
  /// This ensures the app never crashes due to Remote Config issues.
  int getHijriOffset();
}

class HijriRemoteDataSourceImpl implements HijriRemoteDataSource {
  final FirebaseRemoteConfig _remoteConfig;

  /// Key name in Firebase Remote Config for Hijri offset value
  static const String _hijriOffsetKey = 'hijri_offset';

  /// Default value when Remote Config is unavailable or key doesn't exist
  static const int _defaultOffset = 0;

  HijriRemoteDataSourceImpl({required FirebaseRemoteConfig remoteConfig})
    : _remoteConfig = remoteConfig;

  @override
  Future<void> fetchAndActivate() async {
    try {
      // Fetch and activate in one call - more efficient than separate calls
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      // Log error but don't throw - app should continue with default values
      // In production, you might want to log this to Firebase Crashlytics
      // ignore: avoid_print
      print('Failed to fetch Remote Config: $e');
    }
  }

  @override
  int getHijriOffset() {
    try {
      // Safely get the integer value with fallback
      return _remoteConfig.getInt(_hijriOffsetKey);
    } catch (e) {
      // If reading fails for any reason, return default offset
      // This keeps the app functional even if Remote Config has issues
      // ignore: avoid_print
      print('Failed to read hijri_offset from Remote Config: $e');
      return _defaultOffset;
    }
  }
}
