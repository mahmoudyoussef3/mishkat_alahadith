import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/datasources/daily_hadith_notification_datasource.dart';
import 'package:mishkat_almasabih/features/hadith_daily/data/repos/daily_hadith_notification_repo_impl.dart';
import 'package:mishkat_almasabih/features/hadith_daily/domain/usecases/set_daily_hadith_notification_enabled_use_case.dart';

/// Stands in for the reader's choice, the permission and FCM.
class _FakeDataSource implements DailyHadithNotificationDataSource {
  bool permissionGranted = true;
  bool failSync = false;
  final List<bool> savedChoices = [];
  int syncs = 0;

  @override
  Future<bool> isEnabled() async => savedChoices.lastOrNull ?? true;

  @override
  Future<bool> setEnabled(bool enabled) async {
    if (enabled && !permissionGranted) return false;
    savedChoices.add(enabled);
    return true;
  }

  @override
  Future<void> syncSubscription() async {
    syncs++;
    if (failSync) throw StateError('offline');
  }
}

void main() {
  late _FakeDataSource dataSource;
  late SetDailyHadithNotificationEnabledUseCase setEnabled;

  setUp(() {
    dataSource = _FakeDataSource();
    setEnabled = SetDailyHadithNotificationEnabledUseCase(
      DailyHadithNotificationRepoImpl(dataSource),
    );
  });

  test('turning it off saves the choice, then leaves the topic', () async {
    final result = await setEnabled(false);

    expect(result, isA<ApiSuccess<void>>());
    expect(dataSource.savedChoices, [false]);
    expect(dataSource.syncs, 1);
  });

  test('a refused permission saves nothing and says why', () async {
    dataSource.permissionGranted = false;

    final result = await setEnabled(true);

    expect(
      (result as ApiFailure).failure.message,
      FailureMessages.notificationsDenied,
    );
    expect(dataSource.savedChoices, isEmpty);
    expect(dataSource.syncs, 0);
  });

  test('offline, the saved choice still counts as done', () async {
    dataSource.failSync = true;

    final result = await setEnabled(false);

    expect(result, isA<ApiSuccess<void>>());
    expect(dataSource.savedChoices, [false]);
    expect(dataSource.syncs, 1);
  });

  test('an unconfirmed topic change reads as being offline', () async {
    dataSource.failSync = true;

    final result =
        await DailyHadithNotificationRepoImpl(dataSource).syncSubscription();

    expect((result as ApiFailure).failure, isA<NetworkFailure>());
  });
}
