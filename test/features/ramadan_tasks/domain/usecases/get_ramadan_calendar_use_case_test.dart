import 'package:flutter_test/flutter_test.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/domain/repos/ramadan_config_repository.dart';
import 'package:mishkat_almasabih/features/ramadan_tasks/domain/usecases/get_ramadan_calendar_use_case.dart';

class _FakeConfig implements RamadanConfigRepository {
  String start = '2026-02-18';
  int totalDays = 30;
  int offset = 0;

  @override
  Future<void> initializeRemoteConfig() async {}

  @override
  String getRamadanStartGregorian() => start;

  @override
  int getRamadanTotalDays() => totalDays;

  @override
  int getRamadanStartOffset() => offset;
}

int _dayOn(_FakeConfig config, DateTime now) =>
    GetRamadanCalendarUseCase(config, now: () => now)().currentDay;

void main() {
  late _FakeConfig config;

  setUp(() => config = _FakeConfig());

  test('is day 0 before Ramadan starts', () {
    expect(_dayOn(config, DateTime(2026, 2, 17, 23, 59)), 0);
  });

  test('counts the start date as day 1, ignoring the time of day', () {
    expect(_dayOn(config, DateTime(2026, 2, 18, 0, 1)), 1);
    expect(_dayOn(config, DateTime(2026, 2, 18, 23, 59)), 1);
  });

  test('counts days since the start date', () {
    expect(_dayOn(config, DateTime(2026, 3, 1)), 12);
  });

  test('clamps to the configured month length after Ramadan', () {
    config.totalDays = 29;

    expect(_dayOn(config, DateTime(2026, 4, 10)), 29);
  });

  test('falls back to day 1 when the start date is missing or invalid', () {
    config.start = '';
    expect(_dayOn(config, DateTime(2026, 3, 1)), 1);

    config.start = 'not-a-date';
    expect(_dayOn(config, DateTime(2026, 3, 1)), 1);
  });

  test('passes total days and start offset through from the config', () {
    config
      ..totalDays = 29
      ..offset = 1;

    final calendar = GetRamadanCalendarUseCase(config)();

    expect(calendar.totalDays, 29);
    expect(calendar.startOffset, 1);
  });
}
