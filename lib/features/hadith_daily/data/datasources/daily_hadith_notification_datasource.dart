import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mishkat_almasabih/core/notification/notification_choice.dart';

/// The "حديث اليوم" notification, which the server pushes to the devices
/// subscribed to [topic]: the reader's choice, and that subscription.
class DailyHadithNotificationDataSource {
  static const String topic = 'daily_hadith';

  /// On unless the reader turned it off.
  static const NotificationChoice _choice = NotificationChoice(
    'daily_hadith_notification_enabled',
    defaultEnabled: true,
  );

  /// Offline, FCM keeps a topic change queued until it is back online, so
  /// there is no use waiting on it longer.
  static const Duration _topicTimeout = Duration(seconds: 10);

  final FirebaseMessaging Function() _messaging;

  DailyHadithNotificationDataSource({FirebaseMessaging Function()? messaging})
    : _messaging = messaging ?? (() => FirebaseMessaging.instance);

  Future<bool> isEnabled() => _choice.isEnabled();

  Future<bool> setEnabled(bool enabled) => _choice.setEnabled(enabled);

  /// Subscribes to [topic], or leaves it, to match the reader's choice.
  ///
  /// Sent every time rather than remembered: a new FCM token, as after a
  /// restore onto another device, starts out of every topic. Throws when FCM
  /// does not confirm in time; the choice stays saved, so the next call tries
  /// again.
  Future<void> syncSubscription() async {
    final messaging = _messaging();
    await (await _choice.isChosen()
            ? messaging.subscribeToTopic(topic)
            : messaging.unsubscribeFromTopic(topic))
        .timeout(_topicTimeout);
  }
}
