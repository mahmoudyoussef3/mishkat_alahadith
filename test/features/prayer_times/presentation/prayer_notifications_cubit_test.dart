import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/entities/prayer_notification_settings.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/repos/prayer_notifications_repo.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/get_prayer_notification_settings_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/open_battery_optimization_settings_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/reschedule_prayer_notifications_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/domain/usecases/set_prayer_notifications_enabled_use_case.dart';
import 'package:mishkat_almasabih/features/prayer_times/presentation/logic/notifications/prayer_notifications_cubit.dart';

class _FakeRepo implements PrayerNotificationsRepo {
  PrayerNotificationSettings settings = const PrayerNotificationSettings(
    enabled: true,
    batteryOptimizationIgnored: false,
  );
  ApiResult<String> toggleResult = const ApiResult.success('تم التفعيل');
  Completer<void>? holdToggle;
  int toggles = 0;

  @override
  Future<ApiResult<PrayerNotificationSettings>> getSettings() async =>
      ApiResult.success(settings);

  @override
  Future<ApiResult<String>> setEnabled(bool enabled) async {
    toggles++;
    await holdToggle?.future;
    return toggleResult;
  }

  @override
  Future<ApiResult<String>> reschedule() async =>
      const ApiResult.success('تمت المزامنة');

  @override
  Future<void> openBatteryOptimizationSettings() async {}
}

PrayerNotificationsCubit _cubit(_FakeRepo repo) => PrayerNotificationsCubit(
  GetPrayerNotificationSettingsUseCase(repo),
  SetPrayerNotificationsEnabledUseCase(repo),
  ReschedulePrayerNotificationsUseCase(repo),
  OpenBatteryOptimizationSettingsUseCase(repo),
);

void main() {
  late _FakeRepo repo;
  late PrayerNotificationsCubit cubit;

  setUp(() {
    repo = _FakeRepo();
    cubit = _cubit(repo);
  });

  tearDown(() => cubit.close());

  test('load shows the stored settings and the reliability hint', () async {
    await cubit.load();

    expect(cubit.state.enabled, isTrue);
    expect(cubit.state.showBatteryReliabilityAction, isTrue);
  });

  test('a successful toggle updates the switch and reports the message', () async {
    await cubit.toggle(false);

    expect(cubit.state.enabled, isFalse);
    expect(cubit.state.isBusy, isFalse);
    expect(cubit.state.notice?.message, 'تم التفعيل');
    expect(cubit.state.notice?.isError, isFalse);
  });

  test('a failed toggle keeps the switch and reports the error', () async {
    await cubit.load();
    repo.toggleResult = const ApiResult.failure(
      UnexpectedFailure('يجب السماح بالإشعارات'),
    );

    await cubit.toggle(false);

    expect(cubit.state.enabled, isTrue);
    expect(cubit.state.notice?.isError, isTrue);
    expect(cubit.state.notice?.message, 'يجب السماح بالإشعارات');
  });

  test('ignores taps while an update is in flight', () async {
    repo.holdToggle = Completer();

    final first = cubit.toggle(false);
    await cubit.toggle(true);
    repo.holdToggle!.complete();
    await first;

    expect(repo.toggles, 1);
  });

  test('each action produces a new notice even when the text repeats', () async {
    await cubit.refresh();
    final firstNotice = cubit.state.notice;

    await cubit.refresh();

    expect(cubit.state.notice?.message, firstNotice?.message);
    expect(identical(cubit.state.notice, firstNotice), isFalse);
  });
}
