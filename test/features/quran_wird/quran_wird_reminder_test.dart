import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/features/quran_wird/domain/repos/quran_wird_repo.dart';
import 'package:mishkat_almasabih/features/quran_wird/domain/usecases/set_quran_wird_reminder_enabled_use_case.dart';
import 'package:mishkat_almasabih/features/quran_wird/domain/usecases/sync_quran_wird_reminder_use_case.dart';

/// Records what reaches the notification.
class _FakeQuranWirdRepo implements QuranWirdRepo {
  bool enabled;
  bool permissionGranted;
  bool failEnabledRead;
  final List<({int hour, int minute})> scheduled = [];
  int cancels = 0;

  _FakeQuranWirdRepo({
    this.enabled = false,
    this.permissionGranted = true,
    this.failEnabledRead = false,
  });

  @override
  Future<ApiResult<bool>> isReminderEnabled() async =>
      failEnabledRead
          ? const ApiResult.failure(CacheFailure('no choice'))
          : ApiResult.success(enabled);

  @override
  Future<ApiResult<void>> setReminderEnabled(bool enabled) async {
    if (enabled && !permissionGranted) {
      return const ApiResult.failure(UnexpectedFailure('permission'));
    }
    this.enabled = enabled;
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    scheduled.add((hour: hour, minute: minute));
    return const ApiResult.success(null);
  }

  @override
  Future<ApiResult<void>> cancelReminder() async {
    cancels++;
    return const ApiResult.success(null);
  }
}

void main() {
  group('SyncQuranWirdReminderUseCase', () {
    test('schedules the reminder every evening while it is on', () async {
      final repo = _FakeQuranWirdRepo(enabled: true);

      await SyncQuranWirdReminderUseCase(repo)();

      expect(repo.scheduled, [
        (hour: SyncQuranWirdReminderUseCase.reminderHour, minute: 0),
      ]);
      expect(repo.cancels, 0);
    });

    test('clears the reminder while it is off', () async {
      final repo = _FakeQuranWirdRepo();

      await SyncQuranWirdReminderUseCase(repo)();

      expect(repo.scheduled, isEmpty);
      expect(repo.cancels, 1);
    });

    test('leaves the reminder alone when the choice cannot be read', () async {
      final repo = _FakeQuranWirdRepo(failEnabledRead: true);

      final result = await SyncQuranWirdReminderUseCase(repo)();

      expect(result, isA<ApiFailure<void>>());
      expect(repo.scheduled, isEmpty);
      expect(repo.cancels, 0);
    });
  });

  group('SetQuranWirdReminderEnabledUseCase', () {
    SetQuranWirdReminderEnabledUseCase useCaseFor(_FakeQuranWirdRepo repo) =>
        SetQuranWirdReminderEnabledUseCase(
          repo,
          SyncQuranWirdReminderUseCase(repo),
        );

    test('turning it on schedules it at once', () async {
      final repo = _FakeQuranWirdRepo();

      final result = await useCaseFor(repo)(true);

      expect(result, isA<ApiSuccess<void>>());
      expect(repo.enabled, isTrue);
      expect(repo.scheduled, hasLength(1));
    });

    test('turning it off clears it', () async {
      final repo = _FakeQuranWirdRepo(enabled: true);

      await useCaseFor(repo)(false);

      expect(repo.enabled, isFalse);
      expect(repo.cancels, 1);
    });

    test('a refused permission schedules nothing', () async {
      final repo = _FakeQuranWirdRepo(permissionGranted: false);

      final result = await useCaseFor(repo)(true);

      expect((result as ApiFailure).failure.message, 'permission');
      expect(repo.scheduled, isEmpty);
    });
  });
}
