/// Repository interface for Ramadan configuration from Remote Config.
///
/// This abstraction allows the domain layer to remain independent of
/// Firebase implementation details.
///
/// Benefits:
/// - Domain layer doesn't depend on Firebase
/// - Easy to mock for testing
/// - Can swap implementations if needed
/// - Follows Clean Architecture principles
abstract class RamadanConfigRepository {
  /// Initializes and fetches remote configuration from Firebase.
  ///
  /// Should be called once during app initialization.
  /// Safe to call multiple times - implementation handles caching.
  Future<void> initializeRemoteConfig();

  /// Gets the offset for Ramadan start date.
  ///
  /// Use this to adjust when Ramadan month begins based on Shaban moon sighting:
  /// - 0: Use calculated date (Shaban has 30 days) - DEFAULT
  /// - +1: Start 1 day earlier (Shaban has only 29 days)
  /// - -1: Start 1 day later (manual correction)
  ///
  /// Returns a safe value (0) if Remote Config is unavailable.
  int getRamadanStartOffset();

  /// Gets the total number of days in Ramadan month.
  ///
  /// Islamic months are based on moon sighting:
  /// - 30 days: Full month - DEFAULT
  /// - 29 days: Short month (announced after moon sighting)
  ///
  /// Returns 30 if Remote Config is unavailable (safe default).
  int getRamadanTotalDays();

  /// Gets the Gregorian start date of Ramadan.
  ///
  /// Format: 'yyyy-MM-dd' (e.g., '2026-03-19')
  ///
  /// This eliminates country-specific Hijri calculation discrepancies
  /// by using a universal Gregorian reference date.
  ///
  /// Returns empty string if not configured.
  String getRamadanStartGregorian();

  /// Calculates the current Ramadan day number based on Gregorian dates.
  ///
  /// Algorithm:
  /// 1. Get Gregorian start date from Remote Config
  /// 2. Calculate days since start: diff = today.difference(startDate).inDays + 1
  /// 3. Return 0 if Ramadan hasn't started yet (diff < 1)
  /// 4. Otherwise clamp between 1 and total Ramadan days
  ///
  /// Fallback: If Gregorian start date is not configured or invalid, returns 1
  ///
  /// Returns: 0 if Ramadan hasn't started, 1-29 or 1-30 during Ramadan
  int calculateCurrentRamadanDay();
}
