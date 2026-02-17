/// Repository interface for Hijri date configuration.
///
/// This abstraction allows the domain layer to remain independent of
/// the specific data source implementation (Firebase Remote Config in this case).
///
/// Benefits of this abstraction:
/// - UI layer doesn't need to know about Firebase
/// - Easy to mock for testing
/// - Can swap implementation (e.g., use local config for testing)
/// - Follows Dependency Inversion Principle of SOLID
abstract class HijriRepository {
  /// Initializes and fetches remote configuration.
  ///
  /// Should be called once during app initialization.
  /// Safe to call multiple times - implementation handles caching.
  Future<void> initializeRemoteConfig();

  /// Gets the current Hijri date offset in days.
  ///
  /// Returns:
  /// - Positive number: add days to calculated Hijri date
  /// - Negative number: subtract days from calculated Hijri date
  /// - Zero: use calculated date as-is
  ///
  /// Always returns a valid integer, never throws.
  /// Falls back to 0 if configuration is unavailable.
  int getHijriDateOffset();
}
