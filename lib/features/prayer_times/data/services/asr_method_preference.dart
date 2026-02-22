import 'package:egyptian_prayer_times/egyptian_prayer_times.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's chosen Asr juristic method to SharedPreferences.
class AsrMethodPreference {
  static const _key = 'prayer_times_asr_method';

  /// Cached value after the first [load] or [save] call.
  /// Falls back to [AsrMethod.standard] before any async call completes.
  static AsrMethod _cached = AsrMethod.standard;

  /// Returns the stored [AsrMethod], defaulting to [AsrMethod.standard].
  static Future<AsrMethod> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    _cached = _fromString(value);
    return _cached;
  }

  /// Returns the last loaded or saved [AsrMethod] synchronously.
  /// Call [load] at least once (e.g. at app startup) before relying on this.
  static AsrMethod get cached => _cached;

  /// Persists the chosen [AsrMethod].
  static Future<void> save(AsrMethod method) async {
    _cached = method;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, method.name);
  }

  static AsrMethod _fromString(String? value) {
    switch (value) {
      case 'hanafi':
        return AsrMethod.hanafi;
      case 'shafi':
        return AsrMethod.shafi;
      case 'standard':
      default:
        return AsrMethod.standard;
    }
  }

  /// Arabic display label for each method.
  static String arabicLabel(AsrMethod method) {
    switch (method) {
      case AsrMethod.standard:
        return 'قياسي (Standard)';
      case AsrMethod.shafi:
        return 'شافعي';
      case AsrMethod.hanafi:
        return 'حنفي';
    }
  }

  /// All available methods for the picker.
  static const List<AsrMethod> allMethods = AsrMethod.values;
}
