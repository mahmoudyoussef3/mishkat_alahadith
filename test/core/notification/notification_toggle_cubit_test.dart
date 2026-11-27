import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/core/errors/failures.dart';
import 'package:mishkat_almasabih/core/networking/api_result.dart';
import 'package:mishkat_almasabih/core/notification/notification_toggle/notification_toggle_cubit.dart';

/// The saved choice behind a switch, and what saving it does.
class _FakeChoice {
  bool enabled;
  bool failRead;
  ApiResult<void> saveResult;

  /// Whether a failed save still kept the new choice.
  bool keptDespiteFailure;
  Completer<void>? holdSave;
  int saves = 0;

  _FakeChoice({
    this.enabled = false,
    this.failRead = false,
    this.saveResult = const ApiResult.success(null),
    this.keptDespiteFailure = false,
  });

  Future<ApiResult<bool>> read() async =>
      failRead
          ? const ApiResult.failure(CacheFailure('unreadable'))
          : ApiResult.success(enabled);

  Future<ApiResult<void>> save(bool value) async {
    saves++;
    await holdSave?.future;
    if (saveResult is ApiSuccess || keptDespiteFailure) enabled = value;
    return saveResult;
  }
}

NotificationToggleCubit _cubit(_FakeChoice choice) => NotificationToggleCubit(
  isEnabled: choice.read,
  setEnabled: choice.save,
  enabledMessage: 'on',
  disabledMessage: 'off',
);

void main() {
  test('load shows the saved choice without a notice', () async {
    final cubit = _cubit(_FakeChoice(enabled: true));

    await cubit.load();

    expect(cubit.state.enabled, isTrue);
    expect(cubit.state.notice, isNull);
    await cubit.close();
  });

  test('load keeps the switch as it is when the choice cannot be read',
      () async {
    final cubit = _cubit(_FakeChoice(enabled: true, failRead: true));

    await cubit.load();

    expect(cubit.state.enabled, isFalse);
    await cubit.close();
  });

  test('turning it on confirms with the enabled message', () async {
    final cubit = _cubit(_FakeChoice());

    await cubit.toggle(true);

    expect(cubit.state.enabled, isTrue);
    expect(cubit.state.isBusy, isFalse);
    expect(cubit.state.notice?.message, 'on');
    expect(cubit.state.notice?.isError, isFalse);
    await cubit.close();
  });

  test('turning it off confirms with the disabled message', () async {
    final cubit = _cubit(_FakeChoice(enabled: true));
    await cubit.load();

    await cubit.toggle(false);

    expect(cubit.state.enabled, isFalse);
    expect(cubit.state.notice?.message, 'off');
    await cubit.close();
  });

  test('a refused change keeps the switch and says why', () async {
    final cubit = _cubit(
      _FakeChoice(
        saveResult: const ApiResult.failure(UnexpectedFailure('denied')),
      ),
    );

    await cubit.toggle(true);

    expect(cubit.state.enabled, isFalse);
    expect(cubit.state.isBusy, isFalse);
    expect(cubit.state.notice?.message, 'denied');
    expect(cubit.state.notice?.isError, isTrue);
    await cubit.close();
  });

  test('a choice saved before applying it failed shows as kept', () async {
    final cubit = _cubit(
      _FakeChoice(
        saveResult: const ApiResult.failure(NetworkFailure('later')),
        keptDespiteFailure: true,
      ),
    );

    await cubit.toggle(true);

    expect(cubit.state.enabled, isTrue);
    expect(cubit.state.notice?.isError, isTrue);
    await cubit.close();
  });

  test('ignores taps while a change is in flight', () async {
    final choice = _FakeChoice()..holdSave = Completer();
    final cubit = _cubit(choice);

    final first = cubit.toggle(true);
    await cubit.toggle(false);
    choice.holdSave!.complete();
    await first;

    expect(choice.saves, 1);
    expect(cubit.state.enabled, isTrue);
    await cubit.close();
  });

  test('each change produces a new notice even when the text repeats',
      () async {
    final cubit = _cubit(_FakeChoice());
    await cubit.toggle(true);
    final firstNotice = cubit.state.notice;

    await cubit.toggle(true);

    expect(cubit.state.notice?.message, firstNotice?.message);
    expect(identical(cubit.state.notice, firstNotice), isFalse);
    await cubit.close();
  });
}
