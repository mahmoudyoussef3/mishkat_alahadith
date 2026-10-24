import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/datasources/daily_hadith_notification_datasource.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records the topic changes sent to FCM.
class _FakeMessaging extends Fake implements FirebaseMessaging {
  final List<String> calls = [];
  bool fail = false;

  @override
  Future<void> subscribeToTopic(String topic) async {
    if (fail) throw StateError('offline');
    calls.add('subscribe:$topic');
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    if (fail) throw StateError('offline');
    calls.add('unsubscribe:$topic');
  }
}

void main() {
  late _FakeMessaging messaging;
  late DailyHadithNotificationDataSource dataSource;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    messaging = _FakeMessaging();
    dataSource = DailyHadithNotificationDataSource(messaging: () => messaging);
  });

  test('subscribes to the daily hadith topic by default', () async {
    await dataSource.syncSubscription();

    expect(messaging.calls, ['subscribe:daily_hadith']);
  });

  test('sends the subscription every time, so a new token rejoins', () async {
    await dataSource.syncSubscription();
    await dataSource.syncSubscription();

    expect(messaging.calls, [
      'subscribe:daily_hadith',
      'subscribe:daily_hadith',
    ]);
  });

  test('leaves the topic once the reader turns it off', () async {
    await dataSource.syncSubscription();

    // Turning it off asks for no permission, so no platform call is made.
    await dataSource.setEnabled(false);
    await dataSource.syncSubscription();

    expect(messaging.calls, [
      'subscribe:daily_hadith',
      'unsubscribe:daily_hadith',
    ]);
  });

  test('tries again after FCM failed to confirm', () async {
    messaging.fail = true;
    await expectLater(dataSource.syncSubscription(), throwsStateError);

    messaging.fail = false;
    await dataSource.syncSubscription();

    expect(messaging.calls, ['subscribe:daily_hadith']);
  });
}
