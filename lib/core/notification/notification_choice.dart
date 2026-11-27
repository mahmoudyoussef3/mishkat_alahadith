import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The reader's on/off choice for one kind of notification, kept on the
/// device, and honoured only while the system lets the app post
/// notifications.
class NotificationChoice {
  final String _key;
  final bool _defaultEnabled;

  const NotificationChoice(this._key, {required bool defaultEnabled})
    : _defaultEnabled = defaultEnabled;

  /// What the reader chose, whatever the system allows.
  Future<bool> isChosen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? _defaultEnabled;
  }

  /// Chosen, and allowed by the system.
  Future<bool> isEnabled() async =>
      await isChosen() && await Permission.notification.isGranted;

  /// Saves [enabled] and returns whether it was saved: turning it on asks for
  /// the notification permission first, and saves nothing if it is refused.
  Future<bool> setEnabled(bool enabled) async {
    if (enabled && !(await Permission.notification.request()).isGranted) {
      return false;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
    return true;
  }
}
