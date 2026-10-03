import '../repos/ramadan_config_repository.dart';

class RamadanCalendar {
  final int currentDay;

  final int totalDays;

  final int startOffset;

  const RamadanCalendar({
    required this.currentDay,
    required this.totalDays,
    required this.startOffset,
  });
}

class GetRamadanCalendarUseCase {
  final RamadanConfigRepository _repo;
  final DateTime Function() _now;

  GetRamadanCalendarUseCase(this._repo, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  RamadanCalendar call() {
    final totalDays = _repo.getRamadanTotalDays();
    return RamadanCalendar(
      currentDay: _currentDay(totalDays),
      totalDays: totalDays,
      startOffset: _repo.getRamadanStartOffset(),
    );
  }

  int _currentDay(int totalDays) {
    final startDate = _parseGregorianDate(_repo.getRamadanStartGregorian());
    if (startDate == null) return 1;

    final today = _now();
    final todayMidnight = DateTime(today.year, today.month, today.day);
    final diff = todayMidnight.difference(startDate).inDays + 1;

    if (diff < 1) return 0;
    return diff.clamp(1, totalDays);
  }

  DateTime? _parseGregorianDate(String dateString) {
    final parts = dateString.split('-');
    if (parts.length != 3) return null;

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) return null;

    return DateTime(year, month, day);
  }
}
